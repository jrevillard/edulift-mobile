#!/usr/bin/env python3
"""
Coverage Analysis Script - Excludes Generated Files
Calculates real application coverage by architectural layers
"""

import re
import os
from collections import defaultdict
from typing import Dict, List, Tuple

class CoverageAnalyzer:
    def __init__(self, lcov_file: str):
        self.lcov_file = lcov_file
        self.coverage_data = defaultdict(dict)
        self.excluded_patterns = [
            r'\.g\.dart$',      # Generated files
            r'\.freezed\.dart$', # Freezed files
            r'\.mocks\.dart$'   # Mock files
        ]

    def is_excluded(self, file_path: str) -> bool:
        """Check if file should be excluded from coverage analysis"""
        for pattern in self.excluded_patterns:
            if re.search(pattern, file_path):
                return True
        return False

    def parse_lcov(self) -> None:
        """Parse LCOV file and extract coverage data"""
        if not os.path.exists(self.lcov_file):
            print(f"❌ LCOV file not found: {self.lcov_file}")
            return

        with open(self.lcov_file, 'r') as f:
            lines = f.readlines()

        current_file = None
        lines_hit = 0
        lines_found = 0

        for line in lines:
            line = line.strip()

            if line.startswith('SF:'):
                # Source file
                current_file = line[3:]  # Remove 'SF:'

            elif line.startswith('LH:'):
                # Lines hit
                lines_hit = int(line[3:])

            elif line.startswith('LF:'):
                # Lines found
                lines_found = int(line[3:])

            elif line == 'end_of_record':
                # End of record for current file
                if current_file and not self.is_excluded(current_file):
                    if lines_found > 0:
                        coverage_percent = (lines_hit / lines_found) * 100
                        self.coverage_data[current_file] = {
                            'lines_hit': lines_hit,
                            'lines_found': lines_found,
                            'coverage_percent': coverage_percent
                        }

                # Reset for next file
                current_file = None
                lines_hit = 0
                lines_found = 0

    def categorize_by_layer(self) -> Dict[str, Dict]:
        """Categorize files by architectural layer"""
        layers = {
            'domain': defaultdict(list),
            'data': defaultdict(list),
            'presentation': defaultdict(list),
            'core': defaultdict(list),
            'other': defaultdict(list)
        }

        for file_path, coverage in self.coverage_data.items():
            if '/domain/' in file_path:
                feature = self.extract_feature(file_path)
                layers['domain'][feature].append((file_path, coverage))
            elif '/data/' in file_path:
                feature = self.extract_feature(file_path)
                layers['data'][feature].append((file_path, coverage))
            elif '/presentation/' in file_path:
                feature = self.extract_feature(file_path)
                layers['presentation'][feature].append((file_path, coverage))
            elif '/core/' in file_path or file_path.startswith('lib/core/'):
                layers['core']['core'].append((file_path, coverage))
            else:
                layers['other']['misc'].append((file_path, coverage))

        return layers

    def extract_feature(self, file_path: str) -> str:
        """Extract feature name from file path"""
        if '/features/' in file_path:
            parts = file_path.split('/features/')
            if len(parts) > 1:
                feature_parts = parts[1].split('/')
                return feature_parts[0] if feature_parts else 'unknown'
        return 'core'

    def calculate_layer_coverage(self, layer_files: List[Tuple[str, Dict]]) -> Dict:
        """Calculate coverage for a layer"""
        if not layer_files:
            return {'total_lines_hit': 0, 'total_lines_found': 0, 'coverage_percent': 0.0}

        total_lines_hit = sum(coverage['lines_hit'] for _, coverage in layer_files)
        total_lines_found = sum(coverage['lines_found'] for _, coverage in layer_files)

        coverage_percent = (total_lines_hit / total_lines_found * 100) if total_lines_found > 0 else 0.0

        return {
            'total_lines_hit': total_lines_hit,
            'total_lines_found': total_lines_found,
            'coverage_percent': coverage_percent,
            'file_count': len(layer_files)
        }

    def find_low_coverage_files(self, threshold: float = 90.0) -> List[Tuple[str, float]]:
        """Find files with coverage below threshold"""
        low_coverage = []
        for file_path, coverage in self.coverage_data.items():
            if coverage['coverage_percent'] < threshold:
                low_coverage.append((file_path, coverage['coverage_percent']))

        return sorted(low_coverage, key=lambda x: x[1])  # Sort by coverage percentage

    def generate_report(self) -> str:
        """Generate comprehensive coverage report"""
        self.parse_lcov()

        if not self.coverage_data:
            return "❌ No coverage data found or all files excluded"

        layers = self.categorize_by_layer()
        report = []

        # Calculate overall coverage
        total_lines_hit = sum(cov['lines_hit'] for cov in self.coverage_data.values())
        total_lines_found = sum(cov['lines_found'] for cov in self.coverage_data.values())
        overall_coverage = (total_lines_hit / total_lines_found * 100) if total_lines_found > 0 else 0

        report.append("=" * 60)
        report.append("📊 COVERAGE ANALYSIS REPORT (EXCLUDING GENERATED FILES)")
        report.append("=" * 60)
        report.append("")
        report.append(f"🎯 OVERALL COVERAGE: {overall_coverage:.1f}%")
        report.append(f"📊 Total Files Analyzed: {len(self.coverage_data)}")
        report.append(f"🔢 Total Lines: {total_lines_found} (Hit: {total_lines_hit})")
        report.append("")

        # Layer-by-layer analysis
        report.append("📋 COVERAGE BY ARCHITECTURAL LAYER:")
        report.append("-" * 40)

        layer_summaries = {}
        for layer_name, features in layers.items():
            all_files = []
            for feature_files in features.values():
                all_files.extend(feature_files)

            if all_files:
                layer_coverage = self.calculate_layer_coverage(all_files)
                layer_summaries[layer_name] = layer_coverage

                report.append(f"🏗️  {layer_name.upper()}: {layer_coverage['coverage_percent']:.1f}%")
                report.append(f"   Files: {layer_coverage['file_count']}, Lines: {layer_coverage['total_lines_found']}")

                # Feature breakdown for non-core layers
                if layer_name != 'core' and len(features) > 1:
                    for feature, files in features.items():
                        if files:
                            feature_coverage = self.calculate_layer_coverage(files)
                            report.append(f"     └── {feature}: {feature_coverage['coverage_percent']:.1f}%")

        report.append("")

        # Files below 90% coverage
        low_coverage_files = self.find_low_coverage_files(90.0)
        if low_coverage_files:
            report.append("⚠️  FILES BELOW 90% COVERAGE:")
            report.append("-" * 40)
            for file_path, coverage in low_coverage_files[:15]:  # Show top 15
                short_path = file_path.replace('lib/', '')
                report.append(f"📄 {short_path}: {coverage:.1f}%")

            if len(low_coverage_files) > 15:
                report.append(f"   ... and {len(low_coverage_files) - 15} more files")
        else:
            report.append("✅ ALL FILES HAVE 90%+ COVERAGE!")

        report.append("")

        # Recommendations
        report.append("🎯 RECOMMENDATIONS:")
        report.append("-" * 40)

        if overall_coverage < 90:
            report.append("❌ Overall coverage below 90% target")
            report.append("   → Focus on increasing test coverage for low-coverage files")
        else:
            report.append("✅ Overall coverage meets 90% target")

        # Layer-specific recommendations
        for layer_name, coverage_data in layer_summaries.items():
            if coverage_data['coverage_percent'] < 90:
                report.append(f"⚠️  {layer_name.title()} layer below 90%")
                report.append(f"   → Add tests for {layer_name} components")

        report.append("")
        report.append("🔍 Analysis completed excluding:")
        report.append("   • *.g.dart (generated files)")
        report.append("   • *.freezed.dart (freezed files)")
        report.append("   • *.mocks.dart (mock files)")

        return "\n".join(report)

def main():
    analyzer = CoverageAnalyzer("coverage/lcov.info")
    report = analyzer.generate_report()
    print(report)

    # Save report to file
    with open("coverage_report.txt", "w") as f:
        f.write(report)

    print(f"\n💾 Report saved to: coverage_report.txt")

if __name__ == "__main__":
    main()
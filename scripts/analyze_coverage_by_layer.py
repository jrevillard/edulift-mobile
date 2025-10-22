#!/usr/bin/env python3
"""
Flutter Test Coverage Analysis by Architectural Layer
Analyzes LCOV coverage data and categorizes by Clean Architecture layers
"""

import re
from dataclasses import dataclass
from typing import Dict, List, Tuple
import os

@dataclass
class CoverageMetrics:
    lines_found: int = 0
    lines_hit: int = 0
    functions_found: int = 0
    functions_hit: int = 0
    branches_found: int = 0
    branches_hit: int = 0
    
    @property
    def line_coverage(self) -> float:
        return (self.lines_hit / self.lines_found * 100) if self.lines_found > 0 else 0
    
    @property
    def function_coverage(self) -> float:
        return (self.functions_hit / self.functions_found * 100) if self.functions_found > 0 else 0
    
    @property
    def branch_coverage(self) -> float:
        return (self.branches_hit / self.branches_found * 100) if self.branches_found > 0 else 0

@dataclass
class FileCoverage:
    path: str
    metrics: CoverageMetrics
    layer: str

def classify_layer(file_path: str) -> str:
    """Classify file into architectural layer"""
    if '/domain/' in file_path:
        return 'domain'
    elif '/data/' in file_path:
        return 'data'
    elif '/presentation/' in file_path:
        return 'presentation'
    elif file_path.startswith('lib/core/'):
        if '/router/' in file_path or '/navigation/' in file_path:
            return 'presentation'
        elif '/network/' in file_path or '/storage/' in file_path or '/database/' in file_path:
            return 'data'
        elif '/usecases/' in file_path or '/entities/' in file_path:
            return 'domain'
        else:
            return 'core'
    elif file_path.startswith('lib/generated/'):
        return 'generated'
    elif file_path.startswith('lib/main.dart') or '/config/' in file_path:
        return 'app'
    else:
        return 'other'

def parse_lcov_file(lcov_path: str) -> Dict[str, FileCoverage]:
    """Parse LCOV file and extract coverage data by file"""
    files = {}
    current_file = None
    current_metrics = CoverageMetrics()
    
    with open(lcov_path, 'r') as f:
        for line in f:
            line = line.strip()
            
            if line.startswith('SF:'):
                # Start of new file
                current_file = line[3:]  # Remove 'SF:'
                current_metrics = CoverageMetrics()
                
            elif line.startswith('LF:'):
                current_metrics.lines_found = int(line[3:])
                
            elif line.startswith('LH:'):
                current_metrics.lines_hit = int(line[3:])
                
            elif line.startswith('FF:'):
                current_metrics.functions_found = int(line[3:])
                
            elif line.startswith('FH:'):
                current_metrics.functions_hit = int(line[3:])
                
            elif line.startswith('BRF:'):
                current_metrics.branches_found = int(line[4:])
                
            elif line.startswith('BRH:'):
                current_metrics.branches_hit = int(line[4:])
                
            elif line == 'end_of_record' and current_file:
                # End of current file record
                layer = classify_layer(current_file)
                files[current_file] = FileCoverage(
                    path=current_file,
                    metrics=current_metrics,
                    layer=layer
                )
                current_file = None
    
    return files

def aggregate_by_layer(files: Dict[str, FileCoverage]) -> Dict[str, CoverageMetrics]:
    """Aggregate coverage metrics by layer"""
    layers = {}
    
    for file_coverage in files.values():
        layer = file_coverage.layer
        if layer not in layers:
            layers[layer] = CoverageMetrics()
        
        layers[layer].lines_found += file_coverage.metrics.lines_found
        layers[layer].lines_hit += file_coverage.metrics.lines_hit
        layers[layer].functions_found += file_coverage.metrics.functions_found
        layers[layer].functions_hit += file_coverage.metrics.functions_hit
        layers[layer].branches_found += file_coverage.metrics.branches_found
        layers[layer].branches_hit += file_coverage.metrics.branches_hit
    
    return layers

def get_lowest_coverage_files(files: Dict[str, FileCoverage], layer: str, limit: int = 10) -> List[FileCoverage]:
    """Get files with lowest coverage in a specific layer"""
    layer_files = [f for f in files.values() if f.layer == layer and f.metrics.lines_found > 0]
    layer_files.sort(key=lambda x: x.metrics.line_coverage)
    return layer_files[:limit]

def is_critical_domain_file(file_path: str) -> bool:
    """Check if file contains critical business logic"""
    critical_patterns = [
        'usecase', 'use_case', 'repository', 'entity', 'entities',
        'service', 'value_object', 'aggregate', 'domain_service'
    ]
    
    lower_path = file_path.lower()
    return any(pattern in lower_path for pattern in critical_patterns)

def generate_report(files: Dict[str, FileCoverage], output_path: str):
    """Generate comprehensive coverage analysis report"""
    layers = aggregate_by_layer(files)
    
    with open(output_path, 'w') as f:
        f.write("# Flutter Test Coverage Analysis by Architectural Layer\n\n")
        f.write(f"**Analysis Date**: {os.popen('date').read().strip()}\n")
        f.write(f"**Total Files Analyzed**: {len(files)}\n\n")
        
        # Overall Coverage Summary
        f.write("## 📊 Coverage Summary by Layer\n\n")
        f.write("| Layer | Files | Line Coverage | Function Coverage | Branch Coverage |\n")
        f.write("|-------|-------|---------------|-------------------|------------------|\n")
        
        layer_order = ['domain', 'data', 'presentation', 'core', 'app', 'generated', 'other']
        for layer in layer_order:
            if layer in layers:
                metrics = layers[layer]
                file_count = len([f for f in files.values() if f.layer == layer])
                f.write(f"| {layer.title()} | {file_count} | "
                       f"{metrics.line_coverage:.1f}% ({metrics.lines_hit}/{metrics.lines_found}) | "
                       f"{metrics.function_coverage:.1f}% ({metrics.functions_hit}/{metrics.functions_found}) | "
                       f"{metrics.branch_coverage:.1f}% ({metrics.branches_hit}/{metrics.branches_found}) |\n")
        
        f.write("\n")
        
        # Critical Analysis - Domain Layer Focus
        f.write("## 🎯 CRITICAL PRIORITY: Domain Layer Analysis\n\n")
        domain_files = [f for f in files.values() if f.layer == 'domain']
        critical_domain = [f for f in domain_files if is_critical_domain_file(f.path)]
        low_coverage_domain = [f for f in critical_domain if f.metrics.line_coverage < 95]
        
        f.write(f"- **Total Domain Files**: {len(domain_files)}\n")
        f.write(f"- **Critical Business Logic Files**: {len(critical_domain)}\n")
        f.write(f"- **Critical Files <95% Coverage**: {len(low_coverage_domain)}\n\n")
        
        if low_coverage_domain:
            f.write("### 🚨 HIGHEST PRIORITY: Critical Domain Files Needing Coverage\n\n")
            low_coverage_domain.sort(key=lambda x: x.metrics.line_coverage)
            f.write("| File | Line Coverage | Lines Missing | Priority |\n")
            f.write("|------|---------------|---------------|----------|\n")
            
            for file_cov in low_coverage_domain:
                missing = file_cov.metrics.lines_found - file_cov.metrics.lines_hit
                priority = "🔴 CRITICAL" if file_cov.metrics.line_coverage < 80 else "🟡 HIGH"
                f.write(f"| `{file_cov.path}` | {file_cov.metrics.line_coverage:.1f}% | {missing} | {priority} |\n")
            f.write("\n")
        
        # Top 10 Lowest Coverage by Layer
        priority_layers = ['domain', 'data', 'presentation']
        for layer in priority_layers:
            if layer in layers:
                f.write(f"## 📉 Top 10 Lowest Coverage: {layer.title()} Layer\n\n")
                lowest = get_lowest_coverage_files(files, layer, 10)
                
                if lowest:
                    f.write("| Rank | File | Line Coverage | Function Coverage | Lines Missing |\n")
                    f.write("|------|------|---------------|-------------------|---------------|\n")
                    
                    for i, file_cov in enumerate(lowest, 1):
                        missing = file_cov.metrics.lines_found - file_cov.metrics.lines_hit
                        f.write(f"| {i} | `{file_cov.path}` | "
                               f"{file_cov.metrics.line_coverage:.1f}% | "
                               f"{file_cov.metrics.function_coverage:.1f}% | "
                               f"{missing} |\n")
                    f.write("\n")
        
        # Actionable Recommendations
        f.write("## 🎯 Actionable Recommendations for Phase 3.2\n\n")
        f.write("### Immediate Actions (Priority 1)\n\n")
        
        if 'domain' in layers:
            domain_coverage = layers['domain'].line_coverage
            f.write(f"1. **Domain Layer Coverage ({domain_coverage:.1f}%)**\n")
            if domain_coverage < 90:
                f.write("   - 🚨 CRITICAL: Domain coverage below 90% threshold\n")
                f.write("   - Focus on use cases, entities, and repository interfaces\n")
                f.write("   - Target: Achieve 95%+ coverage for all domain files\n")
            f.write("\n")
        
        if 'data' in layers:
            data_coverage = layers['data'].line_coverage  
            f.write(f"2. **Data Layer Coverage ({data_coverage:.1f}%)**\n")
            if data_coverage < 85:
                f.write("   - Focus on repository implementations and data sources\n")
                f.write("   - Test error handling and edge cases\n")
            f.write("\n")
        
        if 'presentation' in layers:
            presentation_coverage = layers['presentation'].line_coverage
            f.write(f"3. **Presentation Layer Coverage ({presentation_coverage:.1f}%)**\n")
            if presentation_coverage < 80:
                f.write("   - Add widget tests and BLoC/provider tests\n")
                f.write("   - Test user interaction flows\n")
            f.write("\n")
        
        f.write("### Coverage Targets by Layer\n\n")
        f.write("| Layer | Current | Target | Action Required |\n")
        f.write("|-------|---------|--------|-----------------|\n")
        
        targets = {'domain': 95, 'data': 85, 'presentation': 80, 'core': 90}
        for layer, target in targets.items():
            if layer in layers:
                current = layers[layer].line_coverage
                action = "✅ Maintain" if current >= target else f"📈 Improve by {target - current:.1f}%"
                f.write(f"| {layer.title()} | {current:.1f}% | {target}% | {action} |\n")
        
        f.write("\n")
        f.write("### Implementation Strategy\n\n")
        f.write("1. **Week 1**: Focus on critical domain files with <80% coverage\n")
        f.write("2. **Week 2**: Address data layer repository implementations\n")  
        f.write("3. **Week 3**: Improve presentation layer widget and state management tests\n")
        f.write("4. **Week 4**: Integration tests and edge case coverage\n\n")
        
        # Coverage Gaps Analysis
        f.write("## 🔍 Detailed Coverage Gaps\n\n")
        
        zero_coverage = [f for f in files.values() if f.metrics.line_coverage == 0 and f.metrics.lines_found > 0]
        if zero_coverage:
            f.write(f"### Files with Zero Coverage ({len(zero_coverage)} files)\n\n")
            zero_coverage.sort(key=lambda x: x.layer)
            current_layer = None
            for file_cov in zero_coverage[:20]:  # Limit to top 20
                if file_cov.layer != current_layer:
                    current_layer = file_cov.layer
                    f.write(f"\n**{current_layer.title()} Layer:**\n")
                f.write(f"- `{file_cov.path}` ({file_cov.metrics.lines_found} lines)\n")
        
        f.write("\n---\n")
        f.write("*Analysis generated using actual LCOV coverage data*\n")

if __name__ == "__main__":
    lcov_path = "/workspace/mobile_app/coverage/lcov.info"
    output_path = "/workspace/mobile_app/coverage_analysis.md"
    
    print("Parsing LCOV file...")
    files = parse_lcov_file(lcov_path)
    print(f"Analyzed {len(files)} files")
    
    print("Generating coverage report...")
    generate_report(files, output_path)
    print(f"Report generated: {output_path}")
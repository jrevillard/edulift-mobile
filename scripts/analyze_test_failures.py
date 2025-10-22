#!/usr/bin/env python3

import json
import sys
from collections import defaultdict, Counter
import re

def analyze_test_failures(json_file_path):
    """
    Systematically analyze test failures from JSON output
    """
    failures = []
    errors = []
    test_info = {}
    
    print("=== UNIT TEST FAILURE ANALYSIS ===")
    print()
    
    with open(json_file_path, 'r') as f:
        for line in f:
            try:
                data = json.loads(line.strip())
                
                # Collect test metadata
                if data.get('type') == 'testStart':
                    test_info[data['test']['id']] = {
                        'name': data['test']['name'],
                        'file': data['test'].get('url', '').replace('file://', '') if data['test'].get('url') else '',
                        'line': data['test'].get('line')
                    }
                
                # Collect failures and errors
                elif data.get('type') == 'error':
                    test_id = data.get('testID')
                    if test_id in test_info:
                        failure_data = {
                            'testID': test_id,
                            'test_name': test_info[test_id]['name'],
                            'file': test_info[test_id]['file'],
                            'line': test_info[test_id]['line'],
                            'error_message': data.get('error', ''),
                            'stack_trace': data.get('stackTrace', ''),
                            'is_failure': data.get('isFailure', False)
                        }
                        
                        if failure_data['is_failure']:
                            failures.append(failure_data)
                        else:
                            errors.append(failure_data)
                            
            except json.JSONDecodeError:
                continue
    
    # Categorize failures
    failure_categories = defaultdict(list)
    
    for failure in failures:
        # Categorize by error type
        error_msg = failure['error_message'].lower()
        
        if 'expected:' in error_msg and 'actual:' in error_msg:
            if 'null' in error_msg:
                failure_categories['Null/Missing Values'].append(failure)
            elif 'no family found' in error_msg or 'family not found' in error_msg:
                failure_categories['Family Error Messages'].append(failure)
            elif 'expected: true' in error_msg and 'actual: <false>' in error_msg:
                failure_categories['Boolean Assertions'].append(failure)
            elif 'expected:' in error_msg and 'actual:' in error_msg:
                failure_categories['Value Mismatches'].append(failure)
        elif 'no matching calls' in error_msg:
            failure_categories['Mock Verification'].append(failure)
        else:
            failure_categories['Other Failures'].append(failure)
    
    # Report results
    print(f"📊 SUMMARY:")
    print(f"   Total Assertion Failures: {len(failures)}")
    print(f"   Total Runtime Errors: {len(errors)}")
    print()
    
    print("📁 FAILURE CATEGORIES:")
    for category, items in failure_categories.items():
        print(f"   {category}: {len(items)}")
        for item in items[:3]:  # Show first 3 examples
            file_short = item['file'].split('/')[-1] if item['file'] else 'unknown'
            print(f"      • {file_short}:{item['line']} - {item['test_name']}")
        if len(items) > 3:
            print(f"      ... and {len(items) - 3} more")
        print()
    
    print("🔥 CRITICAL RUNTIME ERRORS:")
    for error in errors[:5]:  # Show first 5 runtime errors
        file_short = error['file'].split('/')[-1] if error['file'] else 'unknown'
        print(f"   • {file_short}:{error['line']}")
        print(f"     {error['error_message']}")
        print()
    
    # Analyze affected files
    affected_files = Counter()
    for failure in failures + errors:
        if failure['file']:
            file_short = failure['file'].split('/')[-1]
            affected_files[file_short] += 1
    
    print("📄 MOST AFFECTED FILES:")
    for filename, count in affected_files.most_common(10):
        print(f"   {filename}: {count} failures")
    print()
    
    return failure_categories, errors

if __name__ == "__main__":
    json_file = sys.argv[1] if len(sys.argv) > 1 else "/workspace/mobile_app/unit_test_results.json"
    analyze_test_failures(json_file)
#!/bin/bash
# EduLift Mobile - Flavor Runner Script
# Simplifies Flutter flavor commands using convention over configuration
# 
# Convention: flavor name = main entry point name
# Example: e2e flavor → lib/main_e2e.dart
#
# Usage:
#   ./scripts/run_flavor.sh <flavor> [additional flutter args]
#   ./scripts/run_flavor.sh development
#   ./scripts/run_flavor.sh e2e --hot
#   ./scripts/run_flavor.sh staging --release

set -e

# Colors for output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Function to print colored output
log_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_debug() {
    echo -e "${BLUE}🐛 $1${NC}"
}

# Show usage
show_usage() {
    echo "EduLift Mobile - Flavor Runner"
    echo ""
    echo "Usage: $0 <flavor> [additional flutter args]"
    echo ""
    echo "Available flavors:"
    list_available_flavors
    echo ""
    echo "Examples:"
    echo "  $0 development                    # Run development flavor"
    echo "  $0 e2e                           # Run E2E testing flavor"
    echo "  $0 staging --hot                 # Run staging with hot reload"
    echo "  $0 production --release          # Run production in release mode"
    echo "  $0 development -d chrome         # Run development on Chrome"
    echo ""
    echo "Convention: flavor name must match main_<flavor>.dart file"
}

# List available flavors by scanning main_*.dart files
list_available_flavors() {
    cd "$PROJECT_DIR"
    
    if ls lib/main_*.dart 1> /dev/null 2>&1; then
        for file in lib/main_*.dart; do
            if [[ "$file" != "lib/main.dart" ]]; then
                flavor=$(basename "$file" .dart | sed 's/main_//')
                target_file="$file"
                echo "  • $flavor → $target_file"
            fi
        done
    else
        echo "  No flavor entry points found in lib/"
    fi
}

# Validate flavor and get target file
get_target_file() {
    local flavor=$1
    local target_file="lib/main_${flavor}.dart"
    
    cd "$PROJECT_DIR"
    
    if [[ ! -f "$target_file" ]]; then
        log_error "Flavor '$flavor' not found!"
        log_warn "Expected file: $target_file"
        echo ""
        echo "Available flavors:"
        list_available_flavors
        echo ""
        echo "To create a new flavor, create: $target_file"
        return 1
    fi
    
    echo "$target_file"
    return 0
}

# Main execution function
run_flutter_flavor() {
    local flavor=$1
    shift # Remove first argument (flavor)
    
    # Get target file for the flavor
    local target_file
    target_file=$(get_target_file "$flavor")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    log_info "Running Flutter flavor: $flavor"
    log_debug "Target file: $target_file"
    log_debug "Additional args: $*"
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Construct Flutter command
    local flutter_cmd="flutter run --flavor $flavor --target $target_file"
    
    # Add additional arguments
    if [[ $# -gt 0 ]]; then
        flutter_cmd="$flutter_cmd $*"
    fi
    
    log_info "Executing: $flutter_cmd"
    echo ""
    
    # Execute Flutter command
    $flutter_cmd
}

# Main script logic
main() {
    # Check if flavor argument is provided
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_usage
        exit 0
    fi
    
    # Check if we're in the right directory
    if [[ ! -f "$PROJECT_DIR/pubspec.yaml" ]]; then
        log_error "Not in a Flutter project directory!"
        log_warn "Expected to find pubspec.yaml at: $PROJECT_DIR/pubspec.yaml"
        exit 1
    fi
    
    # Check if Flutter is available
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Run the flavor
    run_flutter_flavor "$@"
}

# Execute main function with all arguments
main "$@"
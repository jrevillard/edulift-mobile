#!/bin/bash
# EduLift Mobile - Flavor Builder Script
# Simplifies Flutter build commands using convention over configuration
# 
# Convention: flavor name = main entry point name
# Example: e2e flavor → lib/main_e2e.dart
#
# Usage:
#   ./scripts/build_flavor.sh <flavor> <build_type> [additional flutter args]
#   ./scripts/build_flavor.sh staging apk
#   ./scripts/build_flavor.sh production ipa
#   ./scripts/build_flavor.sh e2e apk --debug

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
    echo "EduLift Mobile - Flavor Builder"
    echo ""
    echo "Usage: $0 <flavor> <build_type> [additional flutter args]"
    echo ""
    echo "Available flavors:"
    list_available_flavors
    echo ""
    echo "Build types:"
    echo "  • apk           → Android APK"
    echo "  • appbundle     → Android App Bundle (for Play Store)"
    echo "  • ipa           → iOS App (macOS only)"
    echo "  • web           → Web build"
    echo ""
    echo "Examples:"
    echo "  $0 development apk              # Build development APK"
    echo "  $0 staging appbundle            # Build staging App Bundle"
    echo "  $0 production ipa               # Build production iOS app"
    echo "  $0 e2e apk --debug             # Build E2E APK in debug mode"
    echo "  $0 staging web                  # Build staging web app"
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

# Validate build type
validate_build_type() {
    local build_type=$1
    
    case "$build_type" in
        apk|appbundle|ipa|web)
            return 0
            ;;
        *)
            log_error "Invalid build type: $build_type"
            echo ""
            echo "Valid build types: apk, appbundle, ipa, web"
            return 1
            ;;
    esac
}

# Main execution function
build_flutter_flavor() {
    local flavor=$1
    local build_type=$2
    shift 2 # Remove first two arguments (flavor and build_type)
    
    # Validate inputs
    local target_file
    target_file=$(get_target_file "$flavor")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    if ! validate_build_type "$build_type"; then
        return 1
    fi
    
    log_info "Building Flutter flavor: $flavor ($build_type)"
    log_debug "Target file: $target_file"
    log_debug "Additional args: $*"
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Construct Flutter command
    local flutter_cmd="flutter build $build_type --flavor $flavor --target $target_file"
    
    # Add additional arguments
    if [[ $# -gt 0 ]]; then
        flutter_cmd="$flutter_cmd $*"
    fi
    
    # Add default release mode if not specified
    if [[ "$*" != *"--debug"* ]] && [[ "$*" != *"--profile"* ]] && [[ "$*" != *"--release"* ]]; then
        flutter_cmd="$flutter_cmd --release"
        log_debug "Adding --release (default for builds)"
    fi
    
    log_info "Executing: $flutter_cmd"
    echo ""
    
    # Execute Flutter command
    if $flutter_cmd; then
        echo ""
        log_info "✅ Build completed successfully!"
        
        # Show output location based on build type
        case "$build_type" in
            apk)
                log_info "📱 APK location: build/app/outputs/flutter-apk/"
                ;;
            appbundle)
                log_info "📦 App Bundle location: build/app/outputs/bundle/"
                ;;
            ipa)
                log_info "🍎 IPA location: build/ios/ipa/"
                ;;
            web)
                log_info "🌐 Web build location: build/web/"
                ;;
        esac
    else
        echo ""
        log_error "❌ Build failed!"
        return 1
    fi
}

# Main script logic
main() {
    # Check if required arguments are provided
    if [[ $# -lt 2 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
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
    
    # Build the flavor
    build_flutter_flavor "$@"
}

# Execute main function with all arguments
main "$@"
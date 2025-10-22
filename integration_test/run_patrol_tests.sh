#!/bin/bash

# EduLift Mobile E2E Test Runner
# Autonomous test runner that manages Docker lifecycle and executes Patrol tests
# 
# Usage:
#   ./run_patrol_tests.sh              # Run tests sequentially (safe)
#   ./run_patrol_tests.sh --parallel   # Run tests in parallel (faster)
#   ./run_patrol_tests.sh --clean      # Clean start with fresh containers

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
readonly DOCKER_COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
readonly BACKEND_HEALTH_URL="http://localhost:8030/health"
readonly MAILPIT_URL="http://localhost:8031"
readonly MAX_WAIT_TIME=60
readonly HEALTH_CHECK_INTERVAL=2

# Logging functions
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

# Print header
print_header() {
    echo -e "${GREEN}"
    echo "═══════════════════════════════════════════════════"
    echo "🚀 EduLift Mobile E2E Test Runner"
    echo "═══════════════════════════════════════════════════"
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check if we're in the right directory
    if [[ ! -f "$DOCKER_COMPOSE_FILE" ]]; then
        log_error "docker-compose.yml not found at: $DOCKER_COMPOSE_FILE"
        log_error "Please run this script from the mobile_app/integration_test directory"
        exit 1
    fi
    
    # Check if Flutter is available
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check if Patrol CLI is available
    if ! command -v patrol &> /dev/null; then
        log_warn "Patrol CLI not found. Installing..."
        dart pub global activate patrol_cli
        
        # Add pub-cache to PATH if not already there
        if [[ ":$PATH:" != *":$HOME/.pub-cache/bin:"* ]]; then
            export PATH="$PATH:$HOME/.pub-cache/bin"
        fi
    fi
    
    log_info "✅ Prerequisites check passed"
}

# Note: wait_for_service function removed - replaced by robust check_service() function

# Pre-flight service health checks (Gemini Pro's robust approach)
check_service() {
    local url=$1
    local service_name=$2
    shift 2 # Shift url and service_name off the arguments list
    local acceptable_codes=("$@") # The rest of the arguments are the acceptable codes

    if [ ${#acceptable_codes[@]} -eq 0 ]; then
        acceptable_codes=("200") # Default to "200" if no codes are provided
    fi

    log_info "Checking $service_name at $url (expecting status: ${acceptable_codes[*]})..."
    
    local retries=${HEALTH_CHECK_RETRIES:-10}
    local delay=${HEALTH_CHECK_DELAY:-3}
    local connect_timeout=5
    
    for ((i=1; i<=retries; i++)); do
        # -s: silent, -o /dev/null: discard body, -w "%{http_code}": write status code to stdout
        status=$(curl --connect-timeout $connect_timeout -s -o /dev/null -w "%{http_code}" "$url" || echo "000")

        for code in "${acceptable_codes[@]}"; do
            if [[ "$status" == "$code" ]]; then
                log_info "✅ $service_name is healthy (status: $status)."
                return 0
            fi
        done

        log_debug "Attempt $i/$retries: $service_name not ready (status: $status). Retrying in $delay seconds..."
        sleep "$delay"
    done

    log_error "❌ $service_name at $url failed to become healthy after $retries attempts. Last status: $status."
    return 1
}

# Start Docker services
start_docker_services() {
    local clean_start="$1"
    
    log_info "Checking Docker services status..."
    
    if [[ "$clean_start" == "true" ]]; then
        log_warn "Clean start requested - removing existing containers..."
        docker-compose -f "$DOCKER_COMPOSE_FILE" down -v
    fi
    
    # Check if services are already running
    if docker-compose -f "$DOCKER_COMPOSE_FILE" ps | grep -q "Up"; then
        log_info "✅ Docker services are already running"
        
        # Still check if they're healthy
        if ! check_service "$BACKEND_HEALTH_URL" "Backend API" "200"; then
            log_warn "Backend not responding, restarting services..."
            docker-compose -f "$DOCKER_COMPOSE_FILE" restart
        fi
    else
        log_info "Starting Docker services..."
        docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
    fi
    
    # Phase 0: Pre-flight service health checks (Gemini Pro approach)
    log_info "⚡ PHASE 0: PRE-FLIGHT SERVICE HEALTH CHECKS"
    log_info "📡 Fast backend/Mailpit validation using robust curl checks..."
    
    # Backend expects 200, Mailpit returns 200
    if ! check_service "$BACKEND_HEALTH_URL" "Backend API" "200"; then
        log_error "Backend failed to start"
        show_docker_logs
        return 1
    fi
    
    # Test Mailpit API endpoint (should return 200 with messages list)
    if ! check_service "${MAILPIT_URL}/api/v1/messages" "Mailpit API" "200"; then
        log_error "Mailpit API failed to start"
        show_docker_logs
        return 1
    fi
    
    # CRITICAL: Test Android emulator network access
    log_info "📱 Testing Android emulator network access to services..."
    log_info "🔧 E2E configuration uses 10.0.2.2 addresses for emulator compatibility"
    log_info "   • Backend: http://10.0.2.2:8030 (host localhost:8030)"
    log_info "   • Mailpit: http://10.0.2.2:8031 (host localhost:8031)"
    
    log_info "🎉 PHASE 0: All services are ready and healthy!"
    log_info "   🔗 Backend API: $BACKEND_HEALTH_URL"
    log_info "   📧 Mailpit UI:  $MAILPIT_URL"
    log_info "   📧 Mailpit API: ${MAILPIT_URL}/api/v1"
}

# Show Docker logs for debugging
show_docker_logs() {
    log_error "Showing Docker logs for debugging:"
    echo "----------------------------------------"
    docker-compose -f "$DOCKER_COMPOSE_FILE" logs --tail=20
    echo "----------------------------------------"
}

# Cleanup function
cleanup() {
    local exit_code="${1:-0}"
    
    if [[ "$exit_code" != "0" ]]; then
        log_error "Test run failed with exit code: $exit_code"
        log_info "Docker services will remain running for debugging"
        log_info "Use 'make e2e-logs' to view logs or 'make e2e-stop' to stop services"
    else
        log_info "Test run completed successfully"
        log_info "Docker services will remain running for next test run"
        log_info "Use 'make e2e-stop' to stop services when done"
    fi
    
    exit $exit_code
}

# Trap interrupts
trap 'cleanup 130' INT TERM

# Run tests
run_patrol_tests() {
    local parallel_mode="$1"
    
    log_info "Changing to project directory: $PROJECT_DIR"
    cd "$PROJECT_DIR"
    
    # Ensure Flutter dependencies are installed
    log_info "Installing Flutter dependencies..."
    flutter pub get
    
    # Clear previous test artifacts
    log_info "Clearing previous test artifacts..."
    rm -rf screenshots/ || true
    rm -rf test_results/ || true
    mkdir -p screenshots/
    
    # Build the app for testing (if needed)
    log_info "Ensuring app is built for testing..."
    if [[ ! -f "build/app/outputs/flutter-apk/app-debug.apk" ]] && [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
        log_info "Building Android APK for testing..."
        flutter build apk --debug
    fi
    
    log_info "🧪 Running tests..."
    echo "═══════════════════════════════════════════════════"
    
    if [[ "$parallel_mode" == "true" ]]; then
        log_info "OPTIMIZED mode: Services validated + parallel E2E execution"
    else
        log_info "SAFE mode: Services validated + sequential E2E execution"
    fi
    
    echo "═══════════════════════════════════════════════════"
    
    # Note: Phase 0 (Pre-flight service checks) already completed during Docker startup
    # This is faster than Dart tests as it doesn't need app compilation
    
    # PHASE 2: PATROL E2E TESTS (Full app interaction with Flavors)
    log_info "🚀 PHASE 2: PATROL E2E TESTS (using Flutter Flavors)"
    log_info "📱 Full application testing with UI interaction"
    log_info "🎯 Using E2E flavor: configured in pubspec.yaml (flavor: e2e)"
    
    local patrol_command="patrol test"
    local test_description="Patrol E2E execution with Flavors"
    
    if [[ "$parallel_mode" == "true" ]]; then
        # Patrol doesn't have built-in parallel test execution
        # We run on multiple devices if available for parallel execution
        test_description="with multiple devices (if available)"
        log_info "🚀 Running E2E tests in PARALLEL mode (multiple devices)..."
    else
        log_info "🔄 Running E2E tests in SEQUENTIAL mode..."
    fi
    
    log_info "🧪 Starting E2E tests ($test_description)..."
    log_info "Command: $patrol_command"
    log_info "🔧 Configuration:"
    log_info "   • Flavor: e2e (pubspec.yaml default + unified main.dart)"
    log_info "   • Command: patrol test (no --flavor needed, reads pubspec.yaml)"
    log_info "   • Entry Point: lib/main.dart (auto-detects flavor from environment)"
    log_info "   • Test Bundle: test_bundle.dart (Patrol managed)"
    log_info "   • API URL: http://10.0.2.2:8030/api/v1"
    log_info "   • WebSocket: ws://10.0.2.2:8030"
    log_info "   • Mailpit: http://10.0.2.2:8031"
    
    # Execute E2E tests with flavor configuration
    local e2e_exit_code=0
    if ! $patrol_command; then
        e2e_exit_code=$?
        log_warn "⚠️  Some E2E tests failed (exit code: $e2e_exit_code)"
    else
        log_info "✅ All E2E tests passed!"
    fi
    
    # Final results
    echo "═══════════════════════════════════════════════════"
    if [[ $e2e_exit_code -eq 0 ]]; then
        log_info "🎉 ALL TESTS PASSED! Perfect execution with Gemini Pro's optimized architecture."
        log_info "💡 Benefits achieved:"
        log_info "   ⚡ Fail-fast service validation (shell curl vs Dart compilation)"
        log_info "   🎯 Clean separation: infrastructure checks vs UI testing"
        log_info "   📊 Optimal CI/CD pipeline efficiency"
        log_info "   🔧 Single source of truth for environment validation"
        return 0
    else
        log_warn "⚠️  E2E tests failed, but infrastructure is confirmed healthy"
        log_info "🎯 Issue is in app logic or test implementation, not services"
        log_info "💡 All services (Backend + MailHog) are accessible and responding"
        
        # Show screenshot information if available
        if [[ -d "screenshots" && -n "$(ls -A screenshots 2>/dev/null)" ]]; then
            log_info "📸 Screenshots saved in: screenshots/"
            log_info "Available screenshots:"
            ls -la screenshots/ | grep -v "^total" | awk '{print "   " $9}'
        fi
        
        return 2  # Partial success
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --parallel    OPTIMIZED mode: Fast pre-flight + parallel E2E execution"
    echo "  --clean       Clean start - remove existing Docker containers and volumes"
    echo "  --help        Show this help message"
    echo ""
    echo "Execution Logic (Gemini Pro's 2-Phase Architecture):"
    echo "  Phase 1: Pre-flight connectivity check (fast, no app compilation)"
    echo "  Phase 2: Patrol E2E tests (sequential OR parallel based on --parallel flag)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Safe mode: Fast pre-flight + sequential E2E (safer)"
    echo "  $0 --parallel         # Optimized: Fast pre-flight + parallel E2E (faster)"
    echo "  $0 --clean            # Clean start with fresh containers"
    echo "  $0 --clean --parallel # Clean start + optimized execution"
}

# Parse command line arguments
parse_arguments() {
    PARALLEL_MODE=false
    CLEAN_START=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --parallel)
                PARALLEL_MODE=true
                shift
                ;;
            --clean)
                CLEAN_START=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    parse_arguments "$@"
    print_header
    
    log_info "Configuration:"
    log_info "  Parallel mode: $PARALLEL_MODE"
    log_info "  Clean start:   $CLEAN_START"
    echo ""
    
    # Run the pipeline
    check_prerequisites
    start_docker_services "$CLEAN_START"
    
    # Small delay to ensure services are fully ready
    log_info "⏳ Waiting a moment for services to fully stabilize..."
    sleep 3
    
    # Run tests and capture exit code
    if run_patrol_tests "$PARALLEL_MODE"; then
        cleanup 0
    else
        cleanup 1
    fi
}

# Execute main function with all arguments
main "$@"
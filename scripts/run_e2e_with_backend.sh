#!/bin/bash
# EduLift Mobile - E2E Testing with Real Backend Services
# Script to set up Docker backend and run Patrol E2E tests

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed and running
check_docker() {
    print_status "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! command -v docker compose &> /dev/null; then
        print_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi
    
    print_success "Docker is installed and running"
}

# Check if Patrol CLI is installed
check_patrol() {
    print_status "Checking Patrol CLI installation..."
    
    if ! command -v patrol &> /dev/null; then
        print_warning "Patrol CLI not found. Installing..."
        dart pub global activate patrol_cli
        
        if ! command -v patrol &> /dev/null; then
            print_error "Failed to install Patrol CLI"
            exit 1
        fi
    fi
    
    print_success "Patrol CLI is available"
}

# Start Docker backend services
start_backend() {
    print_status "Starting Docker backend services..."
    
    # Change to e2e directory
    cd /workspace/e2e
    
    # Pull latest images and build if needed
    if command -v docker-compose &> /dev/null; then
        docker-compose pull
        docker-compose up -d --build
    else
        docker compose pull  
        docker compose up -d --build
    fi
    
    print_status "Waiting for backend services to be healthy..."
    
    # Wait for services to be healthy
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        print_status "Health check attempt $attempt/$max_attempts..."
        
        # Check backend health endpoint
        if curl -f -s http://localhost:8002/api/v1/health > /dev/null; then
            print_success "Backend service is healthy"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_error "Backend services failed to start within timeout"
            docker-compose logs backend-e2e
            exit 1
        fi
        
        sleep 5
        attempt=$((attempt + 1))
    done
    
    # Verify MailHog is accessible
    if curl -f -s http://localhost:8025 > /dev/null; then
        print_success "MailHog service is healthy"
    else
        print_warning "MailHog service may not be ready"
    fi
    
    # Go back to mobile app directory
    cd /workspace/mobile_app
}

# Run Flutter dependencies
setup_flutter() {
    print_status "Setting up Flutter dependencies..."
    
    flutter clean
    flutter pub get
    
    print_success "Flutter dependencies ready"
}

# Check if emulator is running
check_emulator() {
    print_status "Checking Android emulator..."
    
    # List running emulators
    running_emulators=$(adb devices | grep emulator | wc -l)
    
    if [ $running_emulators -eq 0 ]; then
        print_warning "No Android emulator is running"
        print_status "Starting default emulator..."
        
        # Try to start emulator (this assumes AVD is set up)
        emulator -avd Pixel_6_API_33 &
        
        # Wait for emulator to boot
        print_status "Waiting for emulator to boot..."
        adb wait-for-device
        sleep 10
        
        print_success "Emulator started"
    else
        print_success "Android emulator is running"
    fi
}

# Run the E2E tests
run_e2e_tests() {
    print_status "Running Patrol E2E tests with real backend..."
    
    # Set environment variables
    export E2E_TEST=true
    export FLUTTER_TEST_MODE=e2e
    export E2E_ANDROID_EMULATOR=true
    
    # Run tests with detailed output
    patrol test \
        --target integration_test/real_backend_magic_link_e2e_test.dart \
        --verbose \
        --screenshot-on-failure \
        --video-recording \
        --device-id $(adb devices | grep emulator | head -1 | awk '{print $1}')
    
    test_exit_code=$?
    
    if [ $test_exit_code -eq 0 ]; then
        print_success "E2E tests passed successfully!"
    else
        print_error "E2E tests failed with exit code $test_exit_code"
    fi
    
    return $test_exit_code
}

# Clean up function
cleanup() {
    print_status "Cleaning up..."
    
    # Stop Docker services if requested
    if [ "$STOP_DOCKER" = "true" ]; then
        cd /workspace/e2e
        if command -v docker-compose &> /dev/null; then
            docker-compose down
        else
            docker compose down
        fi
        print_success "Docker services stopped"
    fi
}

# Trap cleanup on script exit
trap cleanup EXIT

# Main execution flow
main() {
    print_status "Starting EduLift Mobile E2E Tests with Real Backend"
    print_status "================================================"
    
    # Parse command line arguments
    STOP_DOCKER=false
    for arg in "$@"; do
        case $arg in
            --stop-docker)
                STOP_DOCKER=true
                shift
                ;;
        esac
    done
    
    # Run checks and setup
    check_docker
    check_patrol
    start_backend
    setup_flutter
    check_emulator
    
    # Run the actual tests
    if run_e2e_tests; then
        print_success "✅ All E2E tests completed successfully!"
        exit 0
    else
        print_error "❌ E2E tests failed"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
#!/bin/bash

# Taskey Server Integration Tests
# Tests the server endpoints to ensure they're working correctly

set -e  # Exit on any error

# Configuration
PORT=${PORT:-6000}
BASE_URL="http://localhost:$PORT"
TIMEOUT=5

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print colored output
print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Function to wait for server to be ready
wait_for_server() {
    print_info "Waiting for server to be ready on $BASE_URL..."
    
    for i in {1..10}; do
        if curl -s --max-time $TIMEOUT "$BASE_URL/health" > /dev/null 2>&1; then
            print_info "Server is ready!"
            return 0
        fi
        echo -n "."
        sleep 1
    done
    
    print_fail "Server did not become ready within 10 seconds"
    exit 1
}

# Function to run a test
run_test() {
    local test_name="$1"
    local url="$2"
    local expected_status="$3"
    local expected_content="$4"
    
    ((TESTS_RUN++))
    print_test "$test_name"
    
    # Make the request
    local response=$(curl -s -w "HTTPSTATUS:%{http_code}" --max-time $TIMEOUT "$url")
    local body=$(echo "$response" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
    local status=$(echo "$response" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
    
    # Check status code
    if [ "$status" != "$expected_status" ]; then
        print_fail "$test_name - Expected status $expected_status, got $status"
        return 1
    fi
    
    # Check content if provided
    if [ -n "$expected_content" ]; then
        if echo "$body" | grep -q "$expected_content"; then
            print_pass "$test_name - Status $status, content matches"
        else
            print_fail "$test_name - Status $status correct, but content doesn't match '$expected_content'"
            echo "Response body: $body"
            return 1
        fi
    else
        print_pass "$test_name - Status $status"
    fi
}

# Function to test JSON endpoint
test_json_endpoint() {
    local test_name="$1"
    local url="$2"
    local expected_field="$3"
    local expected_value="$4"
    
    ((TESTS_RUN++))
    print_test "$test_name"
    
    # Make the request and parse JSON
    local response=$(curl -s --max-time $TIMEOUT "$url")
    
    # Check if response is valid JSON
    if ! echo "$response" | python3 -m json.tool > /dev/null 2>&1; then
        print_fail "$test_name - Response is not valid JSON"
        echo "Response: $response"
        return 1
    fi
    
    # Check specific field if provided
    if [ -n "$expected_field" ] && [ -n "$expected_value" ]; then
        local actual_value=$(echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('$expected_field', ''))")
        if [ "$actual_value" = "$expected_value" ]; then
            print_pass "$test_name - JSON field '$expected_field' = '$expected_value'"
        else
            print_fail "$test_name - Expected '$expected_field' = '$expected_value', got '$actual_value'"
            return 1
        fi
    else
        print_pass "$test_name - Valid JSON response"
    fi
}

# Main test execution
main() {
    echo "🧪 Taskey Server Integration Tests"
    echo "================================="
    echo "Testing server at: $BASE_URL"
    echo ""
    
    # Wait for server to be ready
    wait_for_server
    echo ""
    
    # Run tests
    print_info "Running endpoint tests..."
    
    # Test health endpoint
    test_json_endpoint "Health endpoint returns JSON" "$BASE_URL/health"
    test_json_endpoint "Health status is healthy" "$BASE_URL/health" "status" "healthy"
    test_json_endpoint "Health service is Taskey" "$BASE_URL/health" "service" "Taskey"
    
    # Test home endpoint
    run_test "Home page returns HTML" "$BASE_URL/" "200" "Taskey"
    run_test "Home page shows environment" "$BASE_URL/" "200" "Environment.*development"
    
    # Test 404 handling
    run_test "404 for non-existent page" "$BASE_URL/does-not-exist" "404"
    
    # Test various HTTP methods (should work or return proper errors)
    run_test "POST to health endpoint" "$BASE_URL/health" "200"
    
    echo ""
    echo "📊 Test Results"
    echo "==============="
    echo "Tests run: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✅ All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ $TESTS_FAILED tests failed!${NC}"
        exit 1
    fi
}

# Handle Ctrl+C gracefully
trap 'echo ""; print_info "Tests interrupted"; exit 1' INT

# Run main function
main "$@"
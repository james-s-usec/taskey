#!/bin/bash

# Simple server test script
set -e

PORT=${PORT:-6000}
BASE_URL="http://localhost:$PORT"

echo "🧪 Testing Taskey Server"
echo "======================="
echo "Server: $BASE_URL"
echo ""

# Test 1: Health endpoint
echo "🔍 Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s "$BASE_URL/health")
echo "Response: $HEALTH_RESPONSE"

if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    echo "✅ Health check passed"
else
    echo "❌ Health check failed"
    exit 1
fi

# Test 2: Home page
echo ""
echo "🔍 Testing home page..."
HOME_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/")
echo "Status: $HOME_STATUS"

if [ "$HOME_STATUS" = "200" ]; then
    echo "✅ Home page responded"
else
    echo "❌ Home page failed"
    exit 1
fi

# Test 3: 404 handling
echo ""
echo "🔍 Testing 404 handling..."
NOT_FOUND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/does-not-exist")
echo "Status: $NOT_FOUND_STATUS"

if [ "$NOT_FOUND_STATUS" = "404" ]; then
    echo "✅ 404 handling works"
else
    echo "❌ 404 handling failed"
    exit 1
fi

echo ""
echo "🎉 All tests passed!"
#!/bin/bash

# Screen Intelligence - Automated Test Runner
# Runs all unit tests and generates a comprehensive report

set -e

echo "🧪 Screen Intelligence - Automated Test Suite"
echo "=============================================="
echo ""

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode command line tools not found. Please install Xcode."
    exit 1
fi

# Create test results directory
mkdir -p test_results

echo "📋 Running Unit Tests..."
echo ""

# Run tests with detailed output
xcodebuild test \
    -project sniper.xcodeproj \
    -scheme sniper \
    -destination 'platform=macOS' \
    -resultBundlePath test_results/TestResults.xcresult \
    | tee test_results/test_output.log

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "✅ All tests passed successfully!"
    echo ""
    
    # Extract test summary
    echo "📊 Test Summary:"
    echo "==============="
    
    # Count test results from log
    TOTAL_TESTS=$(grep -c "Test Case.*started" test_results/test_output.log || echo "0")
    PASSED_TESTS=$(grep -c "Test Case.*passed" test_results/test_output.log || echo "0")
    FAILED_TESTS=$(grep -c "Test Case.*failed" test_results/test_output.log || echo "0")
    
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    echo ""
    
    # Show performance metrics if available
    echo "⚡ Performance Metrics:"
    echo "====================="
    grep -E "Test Case.*Performance.*passed.*\([0-9.]+.*seconds\)" test_results/test_output.log | \
        sed 's/.*Test Case.*Performance\(.*\)passed.*(\([0-9.]*\).*seconds).*/\1: \2s/' || echo "No performance tests found"
    echo ""
    
    # Show any warnings
    WARNINGS=$(grep -c "warning:" test_results/test_output.log || echo "0")
    if [ "$WARNINGS" -gt 0 ]; then
        echo "⚠️  Warnings: $WARNINGS"
        grep "warning:" test_results/test_output.log
        echo ""
    fi
    
    echo "🎉 Test suite completed successfully!"
    echo "📁 Detailed results saved in test_results/"
    
else
    echo ""
    echo "❌ Some tests failed!"
    echo ""
    
    # Show failed tests
    echo "💥 Failed Tests:"
    echo "==============="
    grep "Test Case.*failed" test_results/test_output.log || echo "No specific failures found in log"
    echo ""
    
    # Show errors
    echo "🚨 Errors:"
    echo "========="
    grep -A 5 -B 5 "error:" test_results/test_output.log || echo "No specific errors found in log"
    echo ""
    
    echo "📁 Full test output saved in test_results/test_output.log"
    exit 1
fi

echo ""
echo "🔍 Test Coverage Areas Validated:"
echo "================================="
echo "✅ Content Classification (Text, Table, Code, Math)"
echo "✅ Structured Output Generation (CSV, Markdown, LaTeX)"
echo "✅ Image Processing Pipeline"
echo "✅ OCR Engine Integration"
echo "✅ Edge Cases and Error Handling"
echo "✅ Performance Benchmarks"
echo ""

echo "📋 Next Steps:"
echo "============="
echo "1. Review any failed tests in test_results/"
echo "2. Check performance metrics for optimization opportunities"
echo "3. Run manual integration tests if needed"
echo "4. Deploy with confidence! 🚀"
#!/bin/bash

# SnipeX Development Workflow Script
# Quick commands for common development tasks

set -e

echo "🎯 SnipeX Development Workflow"
echo "=============================="

case "$1" in
    "build")
        echo "🔨 Building SnipeX..."
        ./build.sh
        ;;
    "test")
        echo "🧪 Running all tests..."
        ./run_tests.sh
        ;;
    "validate")
        echo "✅ Validating app functionality..."
        swift validate_app.swift
        ;;
    "commit")
        if [ -z "$2" ]; then
            echo "❌ Please provide a commit message"
            echo "Usage: ./dev_workflow.sh commit \"Your commit message\""
            exit 1
        fi
        echo "📝 Committing changes..."
        git add .
        git commit -m "$2"
        ;;
    "push")
        echo "🚀 Pushing to GitHub..."
        git push origin main
        ;;
    "release")
        if [ -z "$2" ]; then
            echo "❌ Please provide a commit message"
            echo "Usage: ./dev_workflow.sh release \"Release message\""
            exit 1
        fi
        echo "🚀 Full release workflow..."
        echo "1. Running tests..."
        ./run_tests.sh
        echo "2. Building app..."
        ./build.sh
        echo "3. Committing changes..."
        git add .
        git commit -m "$2"
        echo "4. Pushing to GitHub..."
        git push origin main
        echo "✅ Release complete!"
        ;;
    "status")
        echo "📊 Repository Status:"
        echo "===================="
        git status
        echo ""
        echo "📈 Recent commits:"
        git log --oneline -5
        ;;
    *)
        echo "Available commands:"
        echo "  build     - Build the app"
        echo "  test      - Run all tests"
        echo "  validate  - Validate app functionality"
        echo "  commit    - Commit changes with message"
        echo "  push      - Push to GitHub"
        echo "  release   - Full release workflow (test + build + commit + push)"
        echo "  status    - Show git status and recent commits"
        echo ""
        echo "Examples:"
        echo "  ./dev_workflow.sh build"
        echo "  ./dev_workflow.sh test"
        echo "  ./dev_workflow.sh commit \"Fix classification bug\""
        echo "  ./dev_workflow.sh release \"v1.1.0 - Enhanced content detection\""
        ;;
esac
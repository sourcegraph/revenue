#!/bin/bash

echo "Starting Ktor application in development mode with auto-reload..."
echo "This will:"
echo "- Enable live reload for Kotlin code changes"
echo "- Enable hot reload for Pebble template changes"
echo "- Watch for changes in classes and resources"
echo ""

# Run Gradle with continuous build in the background
echo "Starting continuous build process..."
./gradlew -t build -x test --quiet &
GRADLE_PID=$!

# Wait a moment for initial build
sleep 3

# Start the Ktor server
echo "Starting Ktor server on http://localhost:8080"
./gradlew run

# Clean up on exit
trap "kill $GRADLE_PID 2>/dev/null" EXIT

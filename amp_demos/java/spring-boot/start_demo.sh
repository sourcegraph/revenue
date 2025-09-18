#!/bin/bash

# Start the Spring Boot demo application
echo "Building dependencies and starting Spring Boot demo application..."
./gradlew build -x test --quiet
echo "Starting Spring Boot demo application..."
echo "Application will be available at: http://localhost:8080"
echo ""
./gradlew bootRun --quiet

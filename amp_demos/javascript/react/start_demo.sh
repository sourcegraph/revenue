#!/bin/bash

# Start the React demo application
echo "Installing dependencies..."
pnpm install --silent

echo "Starting React demo application..."
echo "Application will be available at: http://localhost:3000"
echo ""
pnpm start

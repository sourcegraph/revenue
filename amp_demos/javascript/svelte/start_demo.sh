#!/bin/bash

echo "Starting SvelteKit application in development mode with hot reload..."
echo "This will:"
echo "- Enable hot reload for Svelte component changes"
echo "- Enable hot reload for TypeScript/JavaScript changes"
echo "- Watch for changes in routes and layouts"
echo "- Serve the application on all network interfaces"
echo ""

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    pnpm install
    echo ""
fi

# Start the SvelteKit development server
echo "Starting SvelteKit development server on http://localhost:8083"
pnpm run dev

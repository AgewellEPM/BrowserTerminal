#!/bin/bash
# BrowserTerminal Launch Script

# Change to the project directory
cd "$(dirname "$0")"

# Build in release mode for better performance
echo "Building BrowserTerminal..."
swift build -c release

if [ $? -eq 0 ]; then
    echo "Starting BrowserTerminal..."
    ./.build/release/BrowserTerminal
else
    echo "Build failed. Please check the error messages above."
    read -n 1 -s -r -p "Press any key to exit..."
fi
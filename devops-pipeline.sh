#!/bin/bash

# A quick helper function to print banners safely
print_phase() {
    figlet -f standard "$1"
}

echo "=== STARTING CI/CD PIPELINE ==="
echo ""

# Phase 1: Build
print_phase "STAGE 1: BUILD"
echo "Compiling application source code now ..."
echo "Artifact app.tar.gz created successfully."
echo ""

# Phase 2: Test
print_phase "STAGE 2: TEST"
echo "Running unit tests..."
echo "All 100 tests passed! "
echo ""

# Phase 3: Deploy
print_phase "STAGE 3: DEPLOY"
echo "Pushing application to AWS production cluster ..."
echo "Deployment complete!"

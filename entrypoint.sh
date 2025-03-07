#!/bin/bash

# Install npm dependencies
npm install

# Navigate to the circuits directory
cd circuits

# Clone the circomlib repository
if [ ! -d "circomlib" ]; then
    git clone https://github.com/iden3/circomlib.git
fi

# Navigate to the circomlib directory
cd circomlib

# Install npm dependencies for circomlib
npm install

# Navigate back to the root directory
cd ../..

# Run npm tests
npm test
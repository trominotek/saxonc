#!/bin/bash

set -e  # exit on error

# Optional: clean up any previous run
#rm -rf layer python saxonc_layer.zip

# Make sure you're using Python 3.9
python3 --version
pip3 --version

# Install system dependencies (CloudShell already has many, this is a safety net)
sudo dnf -y install python3-pip python3-devel gcc zip unzip wget

# Create Lambda layer structure
mkdir -p layer/python/lib/python3.9/site-packages

# Download SaxonC wheel if not already present
WHEEL="saxoncpe-12.6.0-cp39-cp39-manylinux_2_24_x86_64.whl"
if [ ! -f "$WHEEL" ]; then
    echo "Downloading SaxonC wheel..."
    curl -O https://files.pythonhosted.org/packages/73/4c/b419dbfecd95d26f354c1927713cdf40388f2313ce2d926b2e6a3d361141/saxoncpe-12.6.0-cp39-cp39-manylinux_2_24_x86_64.whl
fi

# Install the wheel into the layer's site-packages
python3 -m pip install "$WHEEL" -t layer/python/lib/python3.9/site-packages

# Create saxonc/__init__.py to expose symbols from saxoncpe.so
mkdir -p layer/python/lib/python3.9/site-packages/saxonc
echo "from saxoncpe import *" > layer/python/lib/python3.9/site-packages/saxonc/__init__.py

# (Optional) show that __init__.py exists
ls -l layer/python/lib/python3.9/site-packages/saxonc

# Create the zip package
cd layer
zip -r9 ../saxonc_layer.zip .
cd ..

echo "✅ Done: saxonc_layer.zip created"

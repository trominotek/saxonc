FROM amazonlinux:2023

# Install Python 3.9 and development tools
RUN dnf -y install python3-pip python3-devel gcc zip && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# Set working directory
WORKDIR /opt

# Prepare Lambda layer directory structure
RUN mkdir -p python/lib/python3.9/site-packages

# Copy the SaxonC wheel into the container
COPY saxoncpe-12.6.0-cp39-cp39-manylinux_2_24_x86_64.whl .

# Install SaxonC wheel into the layer directory
RUN python -m pip install saxoncpe-*.whl -t python/lib/python3.9/site-packages

# Create proper saxonc/ wrapper with __init__.py
RUN mkdir -p python/lib/python3.9/site-packages/saxonc && \
    printf 'from ..saxoncpe import *\n' > python/lib/python3.9/site-packages/saxonc/__init__.py && \
    ls -l python/lib/python3.9/site-packages/saxonc

# Package the layer into a zip file
RUN zip -r /tmp/saxonc_layer.zip python

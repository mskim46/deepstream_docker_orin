#!/bin/bash
set -e

echo "Starting build of imc-deepstream image..."

# Step 1: Setup Jetson build environment.
# The environment has already been set up by buildjet.sh; skip this step.
# echo "Running setup_jetson_build.sh..."
# ../setup_jetson_build.sh

# Step 2: Build base image from docker/Dockerfile_Jetson_Devel.
echo "Building base image (deepstream-l4t:7.1.0-triton-local)..."
sudo docker build --network host --progress=plain -t deepstream-l4t:7.1.0-triton-local -f docker/Dockerfile_Jetson_Devel .

# Step 3: Create a temporary Dockerfile with custom installation commands.
TMP_DOCKERFILE="Dockerfile.imc"
cat > $TMP_DOCKERFILE << 'EOF'
FROM deepstream-l4t:7.1.0-triton-local

# Update package lists and install sudo and ping.
RUN apt update && apt install -y sudo iputils-ping

# Set working directory.
WORKDIR /tmp

# Install OpenSSL 1.1.1 packages.
RUN wget http://ports.ubuntu.com/pool/main/o/openssl/openssl_1.1.1f-1ubuntu2_arm64.deb && \
    wget http://ports.ubuntu.com/pool/main/o/openssl/libssl-dev_1.1.1f-1ubuntu2_arm64.deb && \
    wget http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_arm64.deb && \
    dpkg -i libssl1.1_1.1.1f-1ubuntu2_arm64.deb && \
    dpkg -i libssl-dev_1.1.1f-1ubuntu2_arm64.deb && \
    dpkg -i openssl_1.1.1f-1ubuntu2_arm64.deb && \
    rm -f libssl1.1_1.1.1f-1ubuntu2_arm64.deb libssl-dev_1.1.1f-1ubuntu2_arm64.deb openssl_1.1.1f-1ubuntu2_arm64.deb

# Install prerequisites for AWS SDK for C++.
RUN apt-get update && \
    apt-get install -y libcurl4-openssl-dev libssl-dev uuid-dev zlib1g-dev libpulse-dev

# Build AWS SDK for C++ (DynamoDB only) from source.
RUN git clone --depth 1 --recurse-submodules https://github.com/aws/aws-sdk-cpp.git && \
    mkdir -p sdk_build && cd sdk_build && \
    cmake ../aws-sdk-cpp -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=/usr/local/ -DCMAKE_INSTALL_PREFIX=/usr/local/ -DBUILD_ONLY="dynamodb" && \
    make -j$(nproc) && \
    make install && \
    cd /tmp && rm -rf aws-sdk-cpp sdk_build

EOF

# Step 4: Build the final image with customizations.
echo "Building final image (imc-deepstream:latest)..."
sudo docker build --network host --progress=plain -t imc-deepstream:latest -f $TMP_DOCKERFILE .

# Clean up the temporary Dockerfile.
rm $TMP_DOCKERFILE

echo "Build complete: imc-deepstream:latest is ready."
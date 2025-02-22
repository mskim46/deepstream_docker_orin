#
# SPDX-FileCopyrightText: Copyright (c) 2022-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: MIT
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# extra libs for x86 runtime

utils_install_librdkafka_from_source()
{
    # @{ librdkafka from source;
    echo "Installing librdkafka: "
    apt install -y --no-install-recommends  libssl-dev openssl libssl3 

    cd "/root/tmp"
    git clone https://github.com/confluentinc/librdkafka.git
    cd librdkafka
    git checkout tags/v2.2.0
    ./configure --enable-ssl
    make -j$(nproc)
    make install
    cd "/root/tmp"
    rm -rf librdkafka

    echo "finished installing librdkafka:"
    # @} librdkafka from source;

}

utils_install_libhiredis_from_source()
{
    echo "Installing Dependencies for libhiredis: "
    apt-get install -y --no-install-recommends libglib2.0 libglib2.0-dev make libssl-dev

    echo "Installing libhiredis: "

    cd "/root/tmp"
    git clone https://github.com/redis/hiredis.git
    cd hiredis
    git checkout tags/v1.2.0
    make USE_SSL=1
    cp libhiredis* /opt/nvidia/deepstream/deepstream/lib/
    ln -sf /opt/nvidia/deepstream/deepstream/lib/libhiredis.so /opt/nvidia/deepstream/deepstream/lib/libhiredis.so.1.1.0
    ldconfig
    cd "/root/tmp"
    # apt-get purge -y libssl-dev

    echo "finished installing libhiredis"

}

utils_install_libmosquitto_from_source()
{
    echo "Installing Dependencies: "
    apt-get install -y --no-install-recommends libcjson-dev libssl-dev

    echo "Installing libmosquitto: "
    cd "/root/tmp"
    wget https://mosquitto.org/files/source/mosquitto-2.0.15.tar.gz
    tar -xvf mosquitto-2.0.15.tar.gz
    cd mosquitto-2.0.15
    make
    make install
    cd "/root/tmp"
    rm -rf mosquitto-2.0.15
    echo "finished installing libmosquitto"

}


# This is for x86 only
utils_install_glib_from_source()
{
    echo "Installing Dependencies: "
    apt update
    apt-get install -y --no-install-recommends python3 python3-pip python3-setuptools python3-wheel ninja-build
    pip3 install meson

    echo "Installing glib 2.76.6: "
    cd "/root/tmp"
    git clone https://github.com/GNOME/glib.git
    cd glib
    git checkout 2.76.6
    # meson build --prefix=/usr
    meson setup build --prefix=/usr
    ninja -C build/
    cd build/
    ninja install
    cd "/root/tmp"
    rm -rf glib
    echo "finished installing glib"
}

utils_install_librdkafka_from_source

utils_install_libhiredis_from_source

utils_install_libmosquitto_from_source

utils_install_glib_from_source


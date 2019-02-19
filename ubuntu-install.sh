#!/bin/bash

set -e

# Before running this, make sure system requirements are installed.
#apt-get update
#apt-get -y install build-essential libboost-all-dev libsqlcipher-dev git libcurl4-openssl-dev qt5-default cmake libsqlite3-dev libssl-dev

STAGING_DIR=$(pwd)/build-dtek
INSTALL_DIR=$(pwd)/install-dtek

CC=gcc
CXX=g++

export CXXFLAGS="-I$INSTALL_DIR/include"
export PKG_CONFIG_PATH=$INSTALL_DIR/lib/pkgconfig

OS=`uname -s`
if [[ -z $JOBS ]]; then
    if [[ $OS == Linux ]]; then
        JOBS=`nproc`
    else
        JOBS=2
    fi
fi

echo "Using build JOBS: $JOBS."

function cmake_build()
{
    local REPO=$1
    local NAME=$2
    git clone $REPO
    pushd $NAME > /dev/null
    mkdir build
    pushd build > /dev/null
    cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_DIR ..
    make -j $JOBS install
    popd > /dev/null
    popd > /dev/null
}

function gnumake_build()
{
    local REPO=$1
    local NAME=$2
    local OPTIONS=$3
    git clone $REPO
    pushd $NAME > /dev/null
    ./autogen.sh
    ./configure --prefix=$INSTALL_DIR $OPTIONS
    make -j $JOBS install
    popd > /dev/null
}


rm -rf $STAGING_DIR $INSTALL_DIR
mkdir -p $STAGING_DIR $INSTALL_DIR
pushd $STAGING_DIR > /dev/null

cmake_build https://github.com/HowardHinnant/date date
cmake_build https://github.com/rbock/sqlpp11 sqlpp11
cmake_build https://github.com/rbock/sqlpp11-connector-sqlite3 sqlpp11-connector-sqlite3
cmake_build https://github.com/nlohmann/json json
cmake_build https://github.com/jarro2783/cxxopts cxxopts

gnumake_build https://github.com/zeromq/libzmq libzmq
gnumake_build https://github.com/zeromq/czmq czmq
gnumake_build https://github.com/libbitcoin/secp256k1 secp256k1 "--disable-tests --enable-module-recovery"
gnumake_build https://github.com/narodnik/libbitcoin libbitcoin
gnumake_build https://github.com/narodnik/libbitcoin-database libbitcoin-database

git clone https://github.com/narodnik/dtek/
pushd dtek
qmake darktech.pro
make -j $JOBS
cp darktech $INSTALL_DIR/bin
popd

echo "Type the following before running:"
echo "export LD_LIBRARY_PATH=$INSTALL_DIR/lib"

popd > /dev/null

#!/bin/sh
add-apt-repository ppa:ubuntu-toolchain-r/test
apt-get update
apt-get install gcc-4.9 g++-4.9
updatedb && ldconfig
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 46 
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 49 
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.6 46
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 49
gcc --version

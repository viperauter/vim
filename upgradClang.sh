#!/bin/sh
wget http://llvm.org/releases/3.8.0/llvm-3.8.0.src.tar.xz  
wget http://llvm.org/releases/3.8.0/cfe-3.8.0.src.tar.xz  
wget http://llvm.org/releases/3.8.0/compiler-rt-3.8.0.src.tar.xz  
  
tar xf llvm-3.8.0.src.tar.xz  
mv llvm-3.8.0.src llvm  
  
cp compiler-rt-3.8.0.src.tar.xz ./llvm/projects  
cp cfe-3.8.0.src.tar.xz ./llvm/tools  
  
  
cd ./llvm/tools  
tar xf cfe-3.8.0.src.tar.xz  
mv cfe-3.8.0.src clang  
  
cd ../projects  
tar xf compiler-rt-3.8.0.src.tar.xz  
mv compiler-rt-3.8.0.src compiler-rt  
  
cd ../../  
mkdir build  
cd build  
../llvm/configure --enable-optimized --enable-targets=host-only CC=gcc CXX=g++  
make -j8  
make install  
  
clang --version  
cp ./build/Release+Asserts/lib/libclang.so  ~/.vim/bundle/YouCompleteMe/third_party/ycmd/libclang.so.3.8   

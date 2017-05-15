#!/bin/sh
cdir=`pwd`
#检查是否有git环境
command -v git >/dev/null 2>&1 || { echo "require git but it's not installed.  Aborting." >&2; exit 1; }
command -v ctags >/dev/null 2>&1 || { echo "require ctags but it's not installed.  Aborting." >&2; exit 1; }

#编译需要的vim源码git地址,git上面的7.4.xxx版本不能用
#git url(wget):https://github.com/vim/vim/archive/v7.4.144.tar.gz
#ver=7.4.143
#vimver=v$ver.tar.gz
#sourceurl=https://github.com/vim/vim/archive/$vimver
#if [ ! -f $vimver ];then
#  echo "download the vim source"
#  #wget https://github.com/vim/vim/archive/v7.4.144.tar.gz
#  wget $sourceurl -O $vimver
#fi
#
#tar -xzvf $vimver
#mv "vim-$ver" vim74

#编译需要的vim源码git地址ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2
if [ ! -f vim-7.4.tar.bz2 ];then
  echo "download the vim source"
  wget ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2
fi
tar -xjvf vim-7.4.tar.bz2

#编译需要的vimgdb地址
#git url(wget):https://codeload.github.com/larrupingpig/vimgdb-for-vim7.4/zip/master
if [ ! -f vimgdb-for-vim7.4-master.zip ];then
  echo "download the vimgdm source"
  wget https://codeload.github.com/larrupingpig/vimgdb-for-vim7.4/zip/master -O vimgdb-for-vim7.4-master.zip
fi
unzip vimgdb-for-vim7.4-master.zip

#打补丁
patch -p0 < vimgdb-for-vim7.4-master/vim74.patch
echo y|sudo apt-get install python-dev
echo y|sudo apt-get install libxt-dev

cd $cdir/vim74/src
sed -i "s/BINDIR   = \/opt\/bin/BINDIR   = \/usr\/bin/" Makefile
sed -i "s/MANDIR   = \/opt\/share\/man/MANDIR   = \/usr\/share\/man\/man1/" Makefile
sed -i "s/DATADIR  = \/opt\/share/DATADIR  = \/usr\/share\/vim/" Makefile

ldconfig -p|grep libncurses
if [[ ! $? -eq 0 ]];then
  echo "make vim source"
  sudo apt-get install libncurses5-dev
fi
./configure --enable-gdb --prefix=/usr/local/vim74 --enable-multibyte --enable-fontset --enable-xim --enable-gui=auto --enable-pythoninterp=yes --enable-rubyinterp=dynamic --enable-rubyinterp --enable-perlinterp --enable-cscope --enable-sniff --with-x --with-features=huge --enable-luainterp=dynami --with-python-config-dir=/usr/lib/python2.7/config --with-feature=big

if [ $? -eq 0 ];then
  echo "make vim source"
  make CFLAGS="-O2 -D_FORTIFY_SOURCE=1"
else
  echo "config the vim option error"
fi
make install
cp -rf $cdir/vimgdb-for-vim7.4-master/vimgdb_runtime/* ~/.vim 
echo "vim compile success"
cd /usr/share/vim/vim/vim74/doc/
echo ":helptags ."|vim

#安装bundle
if [ ! -f ~/.vim/bundle/vundle/autoload/vundle.vim ];then
  echo "download bundle\n"
  git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle;
fi
cd $cdir

#生成vim默认配置加载文件.vimrc
vimconfname=.vimrc
vimloadbundle=.vimrc.bundles.local
if [ -f $vimconfname ];then
  rm -rf ./$vimconfname
fi
  
touch $vimconfname
echo  "if &compatible" >> $vimconfname
echo  "  set nocompatible" >> $vimconfname
echo  "end" >> $vimconfname
echo  "filetype off" >> $vimconfname
echo  "set rtp+=~/.vim/bundle/vundle/" >> $vimconfname
echo  "call vundle#rc()" >> $vimconfname
echo  "\" Let Vundle manage Vundle" >> $vimconfname
echo  "Bundle 'gmarik/vundle'" >> $vimconfname
echo  "if filereadable(expand(\"~/.vimrc.bundles.local\"))" >> $vimconfname
echo  '  source ~/.vimrc.bundles.local' >> $vimconfname
echo  "endif" >> $vimconfname
echo  "filetype on" >> $vimconfname
echo  "set previewheight=10" >>$vimconfname
echo  "run macros/gdb_mappings.vim" >>$vimconfname
echo  "set asm=0" >>$vimconfname
echo  "set gdbprg=gdb" >>$vimconfname
echo  "set splitbelow" >>$vimconfname
echo  "set splitright" >>$vimconfname

if [ -f ~/$vimconfname ];then
    mv ~/.vimrc ~/$".vimrc.$(date +"%Y%m%d%I%M%S").bak"
fi

cp ./$vimconfname ~/

#vim的配置文件，使用git中use_vim_as_ide项目配置[https://github.com/yangyangwithgnu/use_vim_as_ide]
#https://codeload.github.com/yangyangwithgnu/use_vim_as_ide/zip/master
if [ ! -f use_vim_as_ide-master.zip ];then
  echo "download the vim config file\n"
  wget https://codeload.github.com/yangyangwithgnu/use_vim_as_ide/zip/master -O use_vim_as_ide-master.zip
fi
unzip use_vim_as_ide-master.zip
cd ./use_vim_as_ide-master/
sed -i "s/^colorscheme solarized/\"colorscheme solarized/" .vimrc 
sed -i "s/set background=dark/set background=light/" .vimrc
sed -i "s/^\"colorscheme phd/colorscheme phd/" .vimrc
cp .vimrc ~/$vimloadbundle
cp README.md ./../
#启动vim安装插件
vim +PluginInstall +qall

#重新配置ycm,从git上下载ubuntu-fix版本
rm -rf ~/.vim/bundle/YouCompleteMe
cd ~/.vim/bundle/
git clone https://git.oschina.net/viperauter/ubuntu-fix.git
cd ~/.vim/bundle/YouCompleteMe/
command -v cmake>/dev/null 2>&1 || { echo y|apt-get install cmake }
git submodule update --init --recursive
./install.py --clang-completer
echo "auto config vim env success"

#打开README
vim README.md





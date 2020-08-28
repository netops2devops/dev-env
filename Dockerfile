# Get latest Debian base container image
FROM debian:latest
MAINTAINER netops2devops "netops2devops@netops2devops.net"

RUN apt update
RUN apt upgrade
RUN apt install -y zsh
RUN apt install -y wget
RUN apt install -y curl
RUN apt install -y git
RUN apt install -y sudo
RUN chsh -s $(which zsh)
RUN apt install -y python
RUN apt install -y python3
RUN apt install -y python3-pip
RUN apt install -y openssh-server
RUN apt install -y python3-distutils python3-dev
RUN apt install -y libncurses5-dev libncursesw5-dev

# clone vim since we need to compile it from source with Python3 to get Jedi-vim working
RUN git clone https://github.com/vim/vim.git /home/devenv/vim
RUN cd /home/devenv/vim && \
./configure \
--enable-perlinterp=yes \
--enable-python3interp=yes \
--enable-pythoninterp=yes \
--enable-rubyinterp=yes \
--enable-cscope \
--enable-gui=auto \
--enable-gtk2-check \
--enable-gnome-check \
--with-features=huge \
--enable-multibyte \
--with-python3-command=python3 && \
make && make install

# Vim package manager
RUN git clone https://github.com/VundleVim/Vundle.vim.git /home/devenv/.vim/bundle/Vundle.vim

RUN useradd -ms /bin/zsh devenv
RUN echo 'devenv:devenv' | chpasswd
WORKDIR /home/devenv
RUN usermod -aG sudo devenv
RUN chmod 777 /home/devenv

# Copy over vim setup with plugins etc.
COPY vim_setup.tar /home/devenv/.vim/vim_setup.tar
COPY vimrc /home/devenv/.vimrc
RUN chown -R devenv /home/devenv/.vim
RUN cd /home/devenv/.vim && tar -xvf vim_setup.tar && rm vim_setup.tar

USER devenv
ENV TERM xterm-256color

# Install oh-my-zsh in the end
# sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

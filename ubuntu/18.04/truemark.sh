#!/usr/bin/env/bash

# To execute this script run the following as root
# bash <(curl http://installs.truemark.io/ubuntu/18.04/truemark.sh)
set -uex

# Allow user to sudo without a password
echo "user    ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/truemark

# Setup vimrc 
cat > /etc/vim/vimrc.local <<EOL
set background=dark
if has("autocmd")
   au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
EOL

# Don't allow root login via ssh
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

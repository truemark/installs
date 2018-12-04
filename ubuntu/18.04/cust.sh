#!/usr/bin/env bash

###############################################################################
# This script applies some TrueMark specific customizations.
# 
# To execute this script run the following as root
# bash <(curl http://download.truemark.io/installs/ubuntu/18.04/cust.sh) 2>&1 | tee -a /var/log/tminstall.log
###############################################################################

if [[ "$(whoami)" != "root" ]]; then
	echo "Script must be run as root"
	exit 1
fi

echo "###############################################################################"
echo "Executing cust.sh"
echo "###############################################################################"
set -x

# Install additional packages
apt-get update && apt-get install \
	bash vim screen tmux htop \
	sysstat dselect dnsutils \
	wget -y

# Allow user to sudo without a password
echo "user    ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/truemark

# Setup vimrc
cat > /etc/vim/vimrc.local <<EOL
set background=dark
if has("autocmd")
   au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
EOL

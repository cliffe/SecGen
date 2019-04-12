#!/bin/bash
# Install all required system packages
apt update
apt install -y python-pip python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools virtualenv nginx python-certbot-nginx libc6-dev-i386 g++-multilib zsh openssl upx bc

# Install python2 package for src_angr
pip install templite

# Install all required python packages
virtualenv -p python3 env
source env/bin/activate
pip install --upgrade -r requirements.txt

echo "Installation complete."

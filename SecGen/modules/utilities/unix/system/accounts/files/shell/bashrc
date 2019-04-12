# .bashrc
# This file is managed by Puppet.  Changes will be overwritten.
# Please edit ~/.bashrc.custom instead of this file!

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Set the prompt
PS1='\u@\h:\w\$ '

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Puppet specific definitions
if [ -f /etc/bashrc.puppet ]; then
  . /etc/bashrc.puppet
fi

# Account holder definitions
if [ -f ~/.bashrc.custom ]; then
  . ~/.bashrc.custom
fi

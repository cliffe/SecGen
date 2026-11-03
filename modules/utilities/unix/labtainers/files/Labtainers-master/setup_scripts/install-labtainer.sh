#!/bin/bash
: <<'END'
This software was created by United States Government employees at 
The Center for the Information Systems Studies and Research (CISR) 
at the Naval Postgraduate School NPS.  Please note that within the 
United States, copyright protection is not available for any works 
created  by United States Government employees, pursuant to Title 17 
United States Code Section 105.   This software is in the public 
domain and is not subject to copyright. 
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

END
read -p "This script will reboot the system when done, press enter to continue"
#
# ensure labtainer paths in .bashrc
#
here=`pwd`
export LABTAINER_DIR=$here/trunk
target=~/.bashrc
grep ":./bin:" $target | grep PATH >>/dev/null
result=$?
if [[ result -ne 0 ]];then
    cat <<EOT >>$target
    if [[ ":\$PATH:" != *":./bin:"* ]]; then 
        export PATH="\${PATH}:./bin:$here/trunk/scripts/designer/bin"
    fi
    export LABTAINER_DIR=$here/trunk
EOT
fi

grep "Labtainer Aliases" $target >>/dev/null
result=$?
if [[ result -ne 0 ]];then
    here=`realpath ../`
    cat <<EOT >>$target
    #
    # Labtainer Aliases
    alias vncstart="vncserver -local :1"
    alias vncstop="vncserver -kill :1"
    alias vncrestart="vncstop && vncstart"
    alias dex="sudo docker exec -it"
    alias cdlab="cd $LABTAINER_DIR/scripts/labtainer-student/"
EOT
fi

if [ ! -h labtainer-student ]; then ln -s trunk/scripts/labtainer-student; fi
if [ ! -h labtainer-instructor ]; then ln -s trunk/scripts/labtainer-instructor; fi
# add link to update script
full=`realpath trunk/setup_scripts/update-labtainer.sh`
ln -sf $full trunk/scripts/labtainer-student/bin/update-labtainer.sh
cd trunk/setup_scripts
found_distrib=`cat /etc/*-release | grep "^DISTRIB_ID" | awk -F "=" '{print $2}'`
if [[ -z "$1" ]]; then
    if [[ -z "$found_distrib" ]]; then
        # fedora gotta be different
        found_distrib=`cat /etc/*-release | grep "^NAME" | awk -F "=" '{print $2}'`
    fi 
    distrib=$found_distrib
else
    distrib=$1
fi
RESULT=0
case "$distrib" in
    Ubuntu)
        echo is ubuntu
        ./install-docker-ubuntu.sh
        RESULT=$?
        ;;

    *)
        if [[ -z "$1" ]]; then
            echo "This install script only supports Ubuntu.  Sorry."
        else
            echo $"Usage: $0 Ubuntu"
        fi
        exit 1
esac
if [[ "$RESULT" -eq 0 ]]; then
    mkdir -p ../logs
    /usr/bin/newgrp docker <<EONG
    source ./pull-all.sh
    /usr/bin/newgrp $USER 
EONG
sudo ./dns-add.py
./getinfo.py
sudo reboot
else
    echo "There was a problem with the installation."
fi

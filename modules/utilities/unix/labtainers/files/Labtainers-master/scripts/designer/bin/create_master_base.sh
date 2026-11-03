#!/bin/bash
#
# Create a master Labtainer image for use in running Labtainers from a container
# on any system that has Docker installed, withou having to install Labtainers.
# Thanks for Olivier Berger for this contribution.
#
here=`pwd`
cd ../
mkdir -p workspace_master
rm -fr workspace_master/*
cp -a $LABTAINER_DIR/headless-lite/Dockerfile.labtainer.master.base workspace_master/Dockerfile.labtainer.headless.base
cp -aR workspace/system workspace_master/
cd workspace_master

cat <<EOT >bashrc.labtainer.master
if [[ ":\$PATH:" != *":./bin:"* ]]; then 
    export PATH="\${PATH}:./bin:/home/labtainer/labtainer/trunk/scripts/designer/bin"
    export LABTAINER_DIR=/home/labtainer/labtainer/trunk
fi
#
# Labtainer Aliases
alias vncstart="vncserver -local :1"
alias vncstop="vncserver -kill :1"
alias vncrestart="vncstop && vncstart"
alias dex="sudo docker exec -it"
alias cdlab="cd $LABTAINER_DIR/scripts/labtainer-student/"
EOT

CACHE="--no-cache"
if [[ "$1" == -c ]]; then
    CACHE=""
fi
docker build $CACHE --build-arg DOCKER_GROUP_ID="$(getent group docker | cut -d: -f3)" -f Dockerfile.labtainer.headless.base -t labtainer.master.base .
docker tag labtainer.master.base labtainers/labtainer.master.base
cd $here

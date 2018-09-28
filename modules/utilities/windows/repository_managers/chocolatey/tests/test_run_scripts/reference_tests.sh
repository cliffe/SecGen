#!/bin/bash

set -e

# Init
SCRIPT_PATH=$(pwd)
BASENAME_CMD="basename ${SCRIPT_PATH}"
SCRIPT_BASE_PATH=`eval ${BASENAME_CMD}`
declare -a ARGS

# Argument Parsing
if [ $# -eq 0 ]; then
  ARGS[0]='windows-2012r2-64a'
  ARGS[1]='1.4.1'
  ARGS[2]='local'
elif [[ $# -lt 3 || $# -gt 4 ]]; then
  echo 'USAGE reference_tests.sh <CONFIG> <PUPPET_AGENT_VER> <LOCAL_OR_FORGE> <MODULE_VERSION>'
  exit 1
else
  ARGS=("$@")
fi

# Figure out where we are in the directory hierarchy
if [ $SCRIPT_BASE_PATH = "test_run_scripts" ]; then
  cd ../../
fi

# Determine if the forge is needed for the test.
if [ ${ARGS[2]} == 'forge' ]; then
  echo 'Testing Module Using Forge Package'
  export BEAKER_FORGE_HOST=api-module-staging.puppetlabs.com
elif [ ${ARGS[2]} == 'local' ]; then
  echo 'Testing Module Using Local Code'
else
  echo 'You must specify "forge" or "local" for test type!'
  echo 'USAGE reference_tests.sh <CONFIG> <PUPPET_AGENT_VER> <LOCAL_OR_FORGE> <MODULE_VERSION>'
  exit 1
fi

# Determine if a module version was specified.
if [ -n "${ARGS[3]}" ]; then
  echo "Using Module Version: ${ARGS[3]}"
  export MODULE_VERSION=${ARGS[3]}
elif [[ $# -eq 3 && ${ARGS[2]} == 'forge' ]]; then
  echo 'WARNING: Running Reference Tests from Forge without Module Version!'
fi

# Sleep so the user has time to read script messages.
sleep 2

export BEAKER_PUPPET_AGENT_VERSION=${ARGS[1]}
export GEM_SOURCE=http://rubygems.delivery.puppetlabs.net

bundle install --without build development test --path .bundle/gems

bundle exec beaker \
  --preserve-hosts onfail \
  --config tests/configs/${ARGS[0]} \
  --debug \
  --tests tests/reference/tests \
  --keyfile ~/.ssh/id_rsa-acceptance \
  --pre-suite tests/reference/pre-suite \
  --load-path tests/lib \
  --type aio
  
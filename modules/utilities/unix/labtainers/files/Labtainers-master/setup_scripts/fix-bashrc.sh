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
target=~/.bashrc
grep ":./bin:" $target >>/dev/null
result=$?
if [[ result -ne 0 ]];then
   cat <<EOT >>$target
   if [[ ":\$PATH:" != *":./bin:"* ]]; then 
      export PATH="\${PATH}:./bin"
   fi
EOT
fi
grep ":scripts/designer/bin:" $target | grep PATH >>/dev/null
result=$?
if [[ result -ne 0 ]];then
   here=`realpath ../`
   cat <<EOT >>$target
   if [[ ":\$PATH:" != *":scripts/designer/bin:"* ]]; then 
      export PATH="\${PATH}:$here/scripts/designer/bin"
      export LABTAINER_DIR=$here
   fi
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

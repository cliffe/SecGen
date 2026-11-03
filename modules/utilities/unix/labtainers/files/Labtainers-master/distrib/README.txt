README for creating a new Labtainers release.
Most of the files herein are not used.
Run 
   ./justrelease.sh tag
to create a new release and push it to github.  The tag field is the version,
see "git tag" output to pick the next version.  See the justrelease.sh script
for details.
Requires setting of the "gitpat" environment variable to push to github.
See ~/Labtainers/gitpat script.

Other files in this directory were used when supporting a more robust development,
test and release procedure, including management of Docker images. That has not been
maintained.

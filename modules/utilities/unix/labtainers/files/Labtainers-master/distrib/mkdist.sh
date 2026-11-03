#!/bin/bash
#
#  Create an end-user distribution of Labtainers.
#  This uses git archive, basing the distribution on committed content of the 
#  current branch of the local repo.
#  use -t to force test registry
#  use -r if this is a release (will force use of master and will not modify README)
#
# NOTE even when making release, CWD is the directory from which the release script
# was executed.
#
function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}
commit=`git describe --always`
skip="skip-labs"
skiplist=""
lines=`cat $skip`
for line in $lines; do
    lab=$(basename $line)
    skiplist+=($lab)
done
mkdir -p /tmp/labtainer_pdf_$USER/labtainer_pdf
here=`pwd`
cd ../
ddir=$(mktemp -d -t labtainer-distrib-XXXXXXXX)
ldir=$ddir/labtainer
ltrunk=$ldir/trunk
scripts=$ltrunk/scripts
labs=$ltrunk/labs
docs=$ltrunk/docs
rm -fr /$ddir
mkdir $ddir
mkdir $ldir
mkdir $ltrunk
if [[ "$1" != "-r" ]]; then
    branch=$(git rev-parse --abbrev-ref HEAD)
else
    release_dir=$HOME/labtainerRelease/Labtainers
    if [[ ! -d $release_dir ]]; then
        echo "No $release_dir directory found"
        exit 
    fi
    echo "Building master from $release_dir"
    cd $release_dir
    branch=master
fi
if [[ "$1" != "-t" ]]; then
    registry=$(scripts/labtainer-student/bin/registry.py)
    echo "Make distribution from branch: $branch  registry: $registry"
else
    echo "Make distribution from branch: $branch  Using premaster registry OVERRIDE"
fi
if [[ "$1" != "-r" ]]; then
    commit=`git describe --always`
    branch=$(git rev-parse --abbrev-ref HEAD)
    sed -i "s/^Distribution created:.*$/Distribution created: $(date '+%m\/%d\/%Y %H:%M') <\/br>/" README.md
    sed -i "s/^Revision:/Previous revision:/" README.md
    sed -i "s/^Commit:.*$/Commit: $commit <\/br>/" README.md
    sed -i "s/^Branch:.*$/Branch: $branch <\/br>/" README.md
fi
cp README.md $ltrunk/
mkdir $scripts
dlist="config setup_scripts docs tool-src distrib/skip-labs scripts/labtainer-student scripts/labtainer-instructor labpacks"
#git archive master config | tar -x -C $ltrunk
for d in $dlist; do
    $here/fix-git-dates.py $d $ltrunk $branch || exit 1
done
mkdir $labs
llist=$(git ls-files labs | cut -d '/' -f 2 | uniq)
for lab in $llist; do
    if [ $(contains "${skiplist[@]}" $lab) != "y" ]; then
        $here/fix-git-dates.py labs/$lab/config $ltrunk $branch || exit 1
        $here/fix-git-dates.py labs/$lab/instr_config $ltrunk $branch || exit 1
        docdir=labs/$lab/docs
        if [[ -d $docdir ]]; then
            if [ "$(ls -A $docdir)" ]; then
               $here/fix-git-dates.py labs/$lab/docs $ltrunk $branch || exit 1
            fi
        fi
        bindir=labs/$lab/bin
        if [[ -d $bindir ]]; then
            if [ "$(ls -A $bindir)" ]; then
                $here/fix-git-dates.py labs/$lab/bin $ltrunk $branch || exit 1
            fi
        fi
    fi
done
distrib/mk-lab-pdf.sh $labs &> /tmp/mk-lab-pdf_$USER.log
result=$?
echo "result of mk-lab-pdf is $result"
if [ $result -ne 0 ]; then
    echo "Trouble making lab manuals"
    exit
fi
cd $ldir
mv trunk/setup_scripts/install-labtainer.sh .
ln -s trunk/setup_scripts/update-labtainer.sh .
ln -s trunk/setup_scripts/update-designer.sh .

cd $ldir/trunk/tool-src/capinout
pwd
./mkit.sh &> /tmp/mkit_$USER.out
# put student and instructor guide at top of distribution.
cp $docs/student/labtainer-student.pdf $ldir/
cp $docs/instructor/labtainer-instructor.pdf $ldir/
cd $ddir
if [[ "$1" != "-r" ]]; then
    tar -cz -X $here/skip-labs -f $here/labtainer.tar labtainer
    cd /tmp/labtainer_pdf_$USER
    zip -qq -r $here/labtainer_pdf.zip labtainer_pdf
else
    mkdir -p $release_dir/distrib/artifacts
    tar -cz -X $here/skip-labs -f $release_dir/distrib/artifacts/labtainer.tar labtainer
    cd /tmp/labtainer_pdf_$USER
    zip -qq -r $release_dir/distrib/artifacts/labtainer_pdf.zip labtainer_pdf
fi
cd $here
rm -fr $ddir
echo "DONE"

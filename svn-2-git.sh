#!/bin/bash -x

EDITOR=${EDITOR:-vim}
GITSVNTEMPDIR=/tmp/svn-2-git.svn.$$
GITBARETEMPDIR=/tmp/svn-2-git.bare.$$
GITTEMPDIR=/tmp/svn-2-git.$$

if [ -z $1 ] ; then exit 1; fi
if [ -z $2 ] ; then depth=0; else depth=$2; fi

rootdir=$1
cd $rootdir
svn update --quiet

fields=1; for i in $(seq 2 $((depth+1))); do fields="$fields,$i"; done

REPOLIST=/tmp/repolist.$$.txt
find . -mindepth $depth -type d | cut -d/ -f$fields |grep -v '\.svn'| uniq > $REPOLIST
### main loop
for repo in $(cat $REPOLIST)
do
    echo ":: $repo"
    #continue
    cd $rootdir/$repo

    GITSVNTEMPDIR=/tmp/svn-2-git.svn.$$/$repo
    GITBARETEMPDIR=/tmp/svn-2-git.bare.$$/$repo
    GITTEMPDIR=/tmp/svn-2-git.$$/$repo

    svn log -q | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2">"}' | sort -u > authors-transform.txt

    authorsfile-strreplace.sh authors-transform.txt
    echo "Edit authors-transform file"
    sleep 1
    $EDITOR authors-transform.txt

    mkdir -p $GITSVNTEMPDIR
    mkdir -p $GITBARETEMPDIR
    mkdir -p $GITTEMPDIR

    SVNURL=$(svn info --show-item url)
    git svn clone $SVNURL --no-metadata -A authors-transform.txt $GITSVNTEMPDIR

    # create bare repo
    git init --bare $GITBARETEMPDIR
    cd $GITBARETEMPDIR
    git symbolic-ref HEAD refs/heads/master

    # push to bare repo
    cd $GITSVNTEMPDIR
    git remote add bare $GITBARETEMPDIR
    git config remote.bare.push 'refs/remotes/*:refs/heads/*'
    git push bare master

    # get a functioning git work dir
    git clone $GITBARETEMPDIR $GITTEMPDIR

done

rm -f $REPOLIST

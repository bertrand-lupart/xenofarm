#!/bin/sh

##############################################
# Xenofarm client
#
# Written by Peter Bortas, Copyright 2002
#
# REQIREMENTS:
#  gzip
#  wget
##############################################

#FIXME: use logger to put stuff in the syslog if available

pidfile=autobuild-`uname -n`.pid
if [ -r $pidfile ]; then
    pid=`cat $pidfile`
    if `kill -0 $pid`; then
        echo "FATAL: Autobuild client already running. pid: $pid"
        exit 1
    else
        echo "NOTE: Removing stale pid-file."
        rm -f $pidfile
    fi
fi

sigint() {
    echo "SIGINT recived. Exiting."
    rm $pidfile
    exit 0    
}
sighup() {
    echo "SIGHUP recived. Exiting for now."
    rm $pidfile
    exit 0
}

trap 1 sighup
trap 2 sigint
trap 15 sigint

echo $$ > $pidfile

if [ ! -x put ]; then
    make put
    if [ ! -x put ]; then
        echo "FATAL: No put command found."
        rm $pidfile
        exit 2
    fi
fi

grep -v \# projects.conf | ( while 
    read project ; do 
    read dir
    read geturl
    read puturl
    read targets

    echo "Building $project in $dir from $geturl with targets: $targets"

    if [ ! -x "$dir" ]; then
        mkdir "$dir"
    fi

    (cd "$dir" &&
     uncompressed=0
     NEWCHECK="`ls -l snapshot.tar.gz`";
     wget --dot-style=binary -N "$geturl" &&
     if [ X"`ls -l snapshot.tar.gz`" == X"$NEWCHECK" ]; then
        echo "NOTE: No newer snapshot for $project available. Skipping."
     fi
     rm -rf buildtmp && mkdir buildtmp && 
     cd buildtmp &&
     for target in `echo $targets`; do
        if [ \! -f "../last_$target" ] ||
           [ "../last_$target" -ot ../../snapshot.tar.gz ]; then
            if [ x"$uncompressed" = x0 ] ; then
              echo "Uncompressing archive..." &&
              (gzip -cd ../snapshot.tar.gz | tar xf -)
              echo "done"
              uncompressed=1
            fi
            cd */. 
            resultdir="../../result_$target"
            rm -rf "$resultdir" && mkdir "$resultdir" &&
            cp export.stamp "$resultdir/" &&
            echo "Building $target" &&
            make $target 2>&1> "$resultdir/RESULT";
            if [ -f autobuild_result.tar.gz ]; then
                mv autobuild_result.tar.gz "$resultdir/"
            else
                (cd "$resultdir" && 
                tar cvf autobuild_result.tar RESULT export.stamp |
                gzip autobuild_result.tar)
            fi
            touch "../../last_$target";
            ../../../put "$puturl" < "$resultdir/autobuild_result.tar.gz" &
            cd ..
        else
            echo "NOTE: Already built $project: $target. Skipping."
        fi
     done )
done )

rm $pidfile
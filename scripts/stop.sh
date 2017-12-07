#!/bin/bash
dir=$(cd `dirname $0`; pwd)
export LD_LIBRARY_PATH=$dir/../luajit/lib:$dir/../nginx/urslib/:$LD_LIBRARY_PATH
bin="$dir/../nginx/sbin/nginx"
if $bin -t;then
    $bin -s stop
    exit 0
else
    exit 1
fi

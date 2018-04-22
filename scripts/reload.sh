#!/bin/bash
dir=$(cd `dirname $0`; pwd)
echo $LD_LIBRARY_PATH 
export LD_LIBRARY_PATH=$dir/../luajit/lib:$dir/../nginx/urslib/:$LD_LIBRARY_PATH
bin="$dir/../nginx/sbin/nginx"
if $bin -t;then
    $bin -s reload
    exit 0
else
    exit 1
fi

#!/bin/bash
dir=$(cd `dirname $0`; pwd)
export LD_LIBRARY_PATH=$dir/../luajit/lib:$dir/../nginx/urslib/:$LD_LIBRARY_PATH
$dir/../nginx/sbin/nginx && exit 0 || exit 1

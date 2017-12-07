#!/bin/bash
#dir=$(cd `dirname $0`; pwd)
#export LD_LIBRARY_PATH=$dir/../luajit/lib:$dir/../nginx/urslib/:$LD_LIBRARY_PATH
#$dir/../nginx/sbin/nginx && exit 0 || exit 1
cd /home/appops/ngx_openresty-1.7.2.1/nginx/conf/lua
export LD_LIBRARY_PATH=/home/appops/ngx_openresty-1.7.2.1/luajit/lib:/home/appops/ngx_openresty-1.7.2.1/nginx/urslib/:$LD_LIBRARY_PATH
/home/appops/ngx_openresty-1.7.2.1/nginx/sbin/nginx && exit 0 || exit 1

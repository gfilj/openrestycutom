#!/bin/bash

set -e
ruby_version=$1
environment=$2
port=$3
migrate_db=$4

if [[ -z $ruby_version ]] || [[ -z $environment ]] || [[ -z $port ]];then
   echo "Usage: $0 ruby_version environment port migrate_db"
   exit 1
fi

#WORK DIR
PRGDIR=`dirname $0`
PRGDIR=`cd $PRGDIR;pwd`
PARENT_DIR=${PRGDIR%/*}
APP_POSTFIX=$(echo $PRGDIR | awk -F / '{ print $6 }')
APP_POSTFIX=$(echo $APP_POSTFIX | cut -d- -f2-)
WORK_DIR="$PARENT_DIR/webroot-$APP_POSTFIX"

# PATH
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

cd $WORK_DIR
rvm use $ruby_version
rvm list

if [ ! -z $migrate_db ];then
  rake db:migrate RAILS_ENV=$environment
fi

exec passenger start -p $port -e $environment

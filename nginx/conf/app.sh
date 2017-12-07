#!/bin/sh
#
# /etc/init.d/tomcat7 -- startup script for the Tomcat 7 servlet engine
#
# Written by Miquel van Smoorenburg <miquels@cistron.nl>.
# Modified for Debian GNU/Linux	by Ian Murdock <imurdock@gnu.ai.mit.edu>.
# Modified for Tomcat by Stefan Gybas <sgybas@debian.org>.
# Modified for Tomcat7 by Thierry Carrez <thierry.carrez@ubuntu.com>.
# Additional improvements by Jason Brittain <jason.brittain@mulesoft.com>.
#
### BEGIN INIT INFO
# Provides:          tomcat7
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Should-Start:      $named
# Should-Stop:       $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start Tomcat.
# Description:       Start the Tomcat servlet engine.
### END INIT INFO

#set -e

# config by freemarker
NAME=tomcat7
#CMDS="/home/monitor/zxh/omadtest/nonjava/software/node-sdk/node-v0.10.33-linux-x64/bin/node /home/monitor/zxh/omadtest/nonjava/nodehw/index.js"

# config locallly
PATH=/bin:/usr/bin:/sbin:/usr/sbin
export PATH
PRGDIR=`dirname $0`
CG_PRGDIR=`dirname $0`
PRGDIR=`cd $PRGDIR;pwd`
DESC="app"
PID_DIR="$PRGDIR/logs"
PID_FILE="$PID_DIR/$NAME.pid"
#CMDS="$2 >$PID_DIR/omad_err.log 2>&1"
CMDS="$2"
export PRGDIR
export CMDS 
PARENT_DIR=${PRGDIR%/*}
APP_POSTFIX=$(echo $PRGDIR | awk -F / '{ print $6 }')
APP_POSTFIX=$(echo $APP_POSTFIX | cut -d- -f2-)
WORK_DIR="$PARENT_DIR/webroot-$APP_POSTFIX"
NAME="$APP_POSTFIX"
# Make sure tomcat is started with system locale
if [ -r /etc/default/locale ]; 
then
	. /etc/default/locale
	export LANG
fi

# load some functions
lsb_release -a  | grep Debian  > /dev/null 2>&1
# load some functions
if [ $? -eq 0 ];
then
	echo "load debian init function"
	. /lib/lsb/init-functions
else
	echo "load other os init function"
	. $CG_PRGDIR/ombin/init-functions
fi

which start-stop-daemon > /dev/null 2>&1
if [ $? -eq 0 ]; then
    	echo "exist,use default start-stop"
else
	PATH=$CG_PRGDIR/ombin/:$PATH
fi

# load rcS
if [ -r /etc/default/rcS ];
then
	. /etc/default/rcS
fi

# ensure PID_DIR
if [ ! -d $PID_DIR ]; 
then
	mkdir $PID_DIR
fi

is_stop() {
	start-stop-daemon --test --start --pidfile "$PID_FILE" --startas "java" >/dev/null;
}

do_start() {
        if [ -d $WORK_DIR ];then
          echo ' work dir is $WORK_DIR'
	  start-stop-daemon --start --pidfile "$PID_FILE" --chdir "$WORK_DIR" -m -b --exec /bin/bash -- -c "$CMDS" >/dev/null 2>&1
        else
          echo ' warnning not set work dir ,use default workdir'
	  start-stop-daemon --start --pidfile "$PID_FILE" -m -b --exec /bin/bash -- -c "$CMDS" >/dev/null 2>&1
	fi 
}

do_stop() {
	start-stop-daemon --stop --pidfile "$PID_FILE" --retry=TERM/20/KILL/5 >/dev/null 2>&1
}

do_exec() {
    start-stop-daemon --start --pidfile "$PID_FILE" -m -b --exec /bin/bash -- -c "$CMDS" >/dev/null 2>&1 
}

case "$1" in
  start)
	log_daemon_msg "Starting $DESC" "$NAME"
	if is_stop;
	then		
		do_start
		sleep 5
		if is_stop;
    	then
			if [ -f "$PID_FILE" ]; then
				rm -f "$PID_FILE"
			fi
			log_end_msg 0 
		else
			log_end_msg 0
		fi
	else
	    log_progress_msg "(already running)"
		log_end_msg 0
	fi
	;;
  stop)
	log_daemon_msg "Stopping $DESC" "$NAME"

	set +e
	if [ -f "$PID_FILE" ]; then 
		do_stop
		if [ $? -eq 1 ]; then
			log_progress_msg "$DESC is not running but pid file exists, cleaning up"
		elif [ $? -eq 3 ]; then
			PID="`cat $PID_FILE`"
			log_failure_msg "Failed to stop $NAME (pid $PID)"
			exit 1
		fi
		rm -f "$PID_FILE"
	else
		log_progress_msg "(not running)"
	fi
	log_end_msg 0
	set -e
	;;
   status)
	set +e
        if [ ! -f "$PID_FILE" ]; then
            echo "pid file not found, please check!"
            exit 1    
        fi
	if is_stop; then
		if [ -f "$PID_FILE" ]; then
		    log_success_msg "$DESC is not running, but pid file exists."
			exit 1
		else
		    log_success_msg "$DESC is not running."
			exit 3
		fi
	else
		log_success_msg "$DESC is running with pid `cat $PID_FILE`"
	fi
	set -e
        ;;
  restart|force-reload)
	set +e
	if [ -f "$PID_FILE" ]; then
		$0 stop "$CMDS"
		sleep 1
	fi
	$0 start "$CMDS"
	if [ $? -ne 0 ]; then
		exit 1
	fi
	set -e
	;;
  pid)
     cat $PID_FILE
     ;;
  exec)
    log_action_msg "Exec command: $CMDS"
    do_exec;
    ;; 
  *)
	log_success_msg "Usage: $0 {start|stop|restart|try-restart|force-reload|status|pid|exec}"
	exit 1
	;;
esac

exit 0


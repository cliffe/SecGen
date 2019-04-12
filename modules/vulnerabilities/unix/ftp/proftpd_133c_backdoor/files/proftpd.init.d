#!/bin/sh 

### BEGIN INIT INFO
# Provides:          proftpd
# Required-Start:    $remote_fs $syslog $local_fs $network
# Required-Stop:     $remote_fs $syslog $local_fs $network
# Should-Start:      $named
# Should-Stop:       $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts ProFTPD daemon
# Description:       This script runs the FTP service offered
#                    by the ProFTPD daemon
### END INIT INFO

# Start the proftpd FTP daemon.

PATH=/bin:/usr/bin:/sbin:/usr/sbin
DAEMON=/usr/local/sbin/proftpd
NAME=proftpd

# Defaults
RUN="no"
OPTIONS=""
CONFIG_FILE=/etc/proftpd/proftpd.conf

PIDFILE=`grep -i 'pidfile' $CONFIG_FILE|sed -e 's/pidfile[\t ]\+//i'`
if [ "x$PIDFILE" = "x" ];
then
	PIDFILE=/var/run/proftpd.pid
fi

# Read config (will override defaults)
[ -r /etc/default/proftpd ] && . /etc/default/proftpd

trap "" 1
trap "" 15

test -f $DAEMON || exit 0

. /lib/lsb/init-functions

#
# Servertype could be inetd|standalone|none.
# In all cases check against inetd and xinetd support.
#
if ! egrep -qi "^[[:space:]]*ServerType.*standalone" $CONFIG_FILE
then
	if egrep -qi "server[[:space:]]*=[[:space:]]*/usr/sbin/proftpd" /etc/xinetd.conf 2>/dev/null || \
	   egrep -qi "server[[:space:]]*=[[:space:]]*/usr/sbin/proftpd" /etc/xinetd.d/* 2>/dev/null || \
       egrep -qi "^ftp.*/usr/sbin/proftpd" /etc/inetd.conf 2>/dev/null
	then
    		RUN="no"
    		INETD="yes"
	else
		if ! egrep -qi "^[[:space:]]*ServerType.*inetd" $CONFIG_FILE
		then
    		RUN="yes"
			INETD="no"
		else
			RUN="no"
			INETD="no"
		fi
	fi
fi

# /var/run could be on a tmpfs

[ ! -d /var/run/proftpd ] && mkdir /var/run/proftpd

inetd_check()
{
	if [ ! -x /usr/sbin/inetd -a ! -x /usr/sbin/xinetd ]; then
		echo "Neither inetd nor xinetd appears installed: check your configuration."
	fi
}

start()
{
    log_daemon_msg "Starting ftp server" "$NAME"

    start-stop-daemon --start --quiet --pidfile "$PIDFILE" --oknodo --exec $DAEMON -- -c $CONFIG_FILE $OPTIONS  
    if [ $? != 0 ]; then
        log_end_msg 1
        exit 1
    else
        log_end_msg 0
    fi
}

signal()
{

    if [ "$1" = "stop" ]; then
		SIGNAL="TERM"
    	log_daemon_msg "Stopping ftp server" "$NAME"
    else
	if [ "$1" = "reload" ]; then
	    SIGNAL="HUP"
    	log_daemon_msg "Reloading ftp server" "$NAME"
	else
	    echo "ERR: wrong parameter given to signal()"
	    exit 1
	fi
    fi
    if [ -f "$PIDFILE" ]; then
    	start-stop-daemon --stop --signal $SIGNAL --quiet --pidfile "$PIDFILE"
   	 if [ $? = 0 ]; then
        	log_end_msg 0
    	else
		SIGNAL="KILL"
		start-stop-daemon --stop --signal $SIGNAL --quiet --pidfile "$PIDFILE"
    		if [ $? != 0 ]; then
        		log_end_msg 1
        		[ $2 != 0 ] || exit 0
    		else
        		log_end_msg 0
    		fi
    	fi
   	if [ "$SIGNAL" = "KILL" ]; then
		rm -f "$PIDFILE"
    	fi
    else
        log_end_msg 0
    fi
}

case "$1" in
    start)
	if [ "x$RUN" = "xyes" ] ; then
	    start
	else
	    start
#	    if [ "x$INETD" = "xyes" ] ; then
#		echo "ProFTPD is started from inetd/xinetd."
#		inetd_check
#	    else
#	    	echo "ProFTPD warning: cannot start neither in standalone nor in inetd/xinetd mode. Check your configuration."
#	    fi
	fi
	;;

    force-start)
	if [ "x$INETD" = "xyes" ] ; then
	    echo "Warning: ProFTPD is started from inetd/xinetd (trying to start anyway)."
		inetd_check
	fi
	start
	;;	
    
    stop)
	if [ "x$RUN" = "xyes" ] ; then
	    signal stop 0
	else
	    if [ "x$INETD" = "xyes" ] ; then
		echo "ProFTPD is started from inetd/xinetd."
		inetd_check
	    else 
	    	echo "ProFTPD warning: cannot start neither in standalone nor in inetd/xinetd mode. Check your configuration."
	    fi
	fi
	;;

    force-stop)
	if [ "x$INETD" = "xyes" ] ; then
	    echo "Warning: ProFTPD is started from inetd/xinetd (trying to kill anyway)."
		inetd_check
	fi
	signal stop 0
	;;

    reload)
	signal reload 0
	;;

    force-reload|restart)
	if [ "x$RUN" = "xyes" ] ; then
	    signal stop 1
	    sleep 2
	    start
	else
	    if [ "x$INETD" = "xyes" ] ; then
		echo "ProFTPD is started from inetd/xinetd."
		inetd_check
	    else 
	    	echo "ProFTPD warning: cannot start neither in standalone nor in inetd/xinetd mode. Check your configuration."
	    fi
	fi
	;;

    status)
	if [ "x$INETD" = "xyes" ] ; then
	    echo "ProFTPD is started from inetd/xinetd."
		inetd_check
		exit 0
	else 
	    if [ -f "$PIDFILE" ]; then
	    	pid=$(cat $PIDFILE)
	    else
	    	pid="x"
	    fi
	    if [ `pidof proftpd|grep "$pid"|wc -l` -ne 0 ] ; then
	    	echo "ProFTPD is started in standalone mode, currently running."
			exit 0
	    else
	    	echo "ProFTPD is started in standalone mode, currently not running."
			exit 3
	    fi
	fi
	;;

    check-config)
        $DAEMON -t >/dev/null && echo "ProFTPD configuration OK" && exit 0
        exit 1
        ;;

    *)
	echo "Usage: /etc/init.d/$NAME {start|status|force-start|stop|force-stop|reload|restart|force-reload|check-config}"
	exit 1
	;;
esac

exit 0

#!/bin/bash

app="sipinter_email_service.py"
maxInstance=1
acummulator=1
exprdefault=0

pidfile="sipinter_email_service.pid"
trxname="sipinter_email_service"
trxlog="out-sipinter_email_service.log"

case $1 in
start)
	#check number of currently running instances
	if [ -f $pidfile ];
	then
		pids=$(<$pidfile)
		pidArr=($pids)
		exprdefault=${#pidArr[@]}
		if [ "$maxInstance" -le "${#pidArr[@]}" ];
		then
			echo "Too many instance running, please stop one of them"
			exit 2
		fi
	else
		#backup the previous log
		if [ -f $trxlog ];			
		then
			curdate=`date +%Y%m%d_%H%M%S`
			if [ ! -d "log" ];
			then
				mkdir "log"
			fi
			mv $trxlog log/$trxlog.$curdate.log
		fi
	fi

	#start the app
	finalexpr=$(expr $acummulator + $exprdefault)
	echo "Starting $trxname"
	#enter to virtual environtment
	source /var/www/python_services/venv/bin/activate
	#run app in background
	nohup python3 $app > $trxlog 2>&1 &

	pid=$!
	echo "$trxname started ($pid)"

	#save the pid into file	
	if [ -f $pidfile ];
	then
		echo -n " $pid" >> $pidfile
	else
		#backup the previous log
		if [ -f $trxlog ];			
		then
			curdate=`date +%Y%m%d_%H%M%S`
			mv $trxlog log/$trxlog.$curdate.log
		fi
		echo -n $pid > $pidfile
	fi
	;;
stop)
	if [ -f $pidfile ];
	then
		#stop app
		pids=$(<$pidfile)
		pidArr=($pids)
		
		lastPid=${pidArr[@]: -1:1}

		kill -15 $lastPid
		echo "Please wait for 2 Seconds to kill application"
		sleep 2
		kill -9 $lastPid
		echo "$trxname with pid=$lastPid has been stopped"

		#rewrite pidfile
		if [ 1 = ${#pidArr[@]} ];
		then
			rm -f $pidfile
		else
			afterPid=("${pidArr[@]/$lastPid}")
			echo -n "${afterPid[@]}" > $pidfile
		fi
	else
		echo "Previous instance not found, please start it first"
	fi
	;;
stop-all)
	#stop all m2mcontroller
	pids=$(<$pidfile)
        
	kill -15 $pids		
	echo "Please wait for 2 seconds to kill application"
	sleep 2
	echo "Stoping all $trxname with $pids"	
	kill -9 $pids
	rm -f $pidfile	
	;;
*)
	echo "Command not recognize, please check parameters"
	exit 1
	;;
esac

exit 0

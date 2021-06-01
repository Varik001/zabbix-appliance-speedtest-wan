#!/usr/bin/env sh

set -e

CACHE_FILE=/var/log/zabbix-speedtest.log
LOCK_FILE=/run/lock/zabbix-speedtest.lock

SPEEDTEST_CMD=speedtest-cli
#SPEEDTEST_CMD=speedtest

run_speedtest() {
	# Lock
	if [ -e "$LOCK_FILE" ]
	then
		echo "A speedtest is already running" >&2
		exit 2
	fi
	touch "$LOCK_FILE"

	#Invoke rm LOCK_FILE on exit
	trap "rm -rf $LOCK_FILE" EXIT HUP INT QUIT PIPE TERM

	#Variable declaration
	local output server_id server_sponsor country location ping download upload

	#Check if argument supplied to function, exec speedtest command and save output
	if [ -z "$1" ]
	then
		output=$("$SPEEDTEST_CMD" --simple)
	else
		output=$("$SPEEDTEST_CMD" --server "$1" --simple)
		CACHE_FILE+="_$1"
	fi

	#Debug
	#echo "Output: $output"

	#Extract and convert with only two decimal
	#ping=$(echo "$output" | grep -n 'Ping: ' | awk '{ printf("%.2f\n", $1) }')
	#Extract and convert to Mbit/s with only two decimal
	#download=$(echo "$output" | grep -n 'Download: ' | awk '{ printf("%.2f\n", $1) }')
	#upload=$(echo "$output" | grep -n 'Upload:' | awk '{ printf("%.2f\n", $1) }')

	#Send value to CACHE_FILE
	{
		echo "$output"

	} > "$CACHE_FILE"

	CACHE_FILE=/etc/zabbix/script/speedtest.log

	# Make sure to remove the lock file (may be redundant)
	rm -rf "$LOCK_FILE"
}

display_help() {
	echo "Usage with this parameters"
	echo
	echo "                          Run the speedtest collector with default setting (best server)"
	echo "   -l xxx                 Run the speedtest collector on the server with id xxx"
	echo "   -a, --all              Run the speedtest collector on the all servers listed in array and the best server"
	echo "   -g, --get-all          Get all server on which run the speedtest with -a"
	echo "   -c, --cached           Get the result for the last speedtest with default setting"
	echo "   -u, --upload           Get the upload speed for the last speedtest with default setting"
	echo "   -d, --download         Get the download speed for the last speedtest with default setting"
	echo "   -p, --ping             Get the ping value for the last speedtest with default setting"
	echo "   -f, --force            Force delete of lock and run the speedtest collector"
	echo "   -h, --help             View this help"
	echo "   -[c|u|d|p] -l xxx      Get the result for the last speedtest on the server with id xxx"
	echo
}

check_cache_exist() {
	if [ ! -e "$1" ]
	then
		echo "Not yet runned the speedtest" >&2
		exit 2
	fi
}

if [ $# -eq 0 ] || [ $# -eq 1 ]
then
	case "$1" in
		-c|--cached)
			check_cache_exist "$CACHE_FILE"
			cat "$CACHE_FILE"
			;;
		-u|--upload)
			check_cache_exist "$CACHE_FILE"
			awk '/Upload/ { print $2 }' "$CACHE_FILE"
			;;
		-d|--download)
			check_cache_exist "$CACHE_FILE"
			awk '/Download/ { print $2 }' "$CACHE_FILE"
			;;
		-p|--ping)
			check_cache_exist "$CACHE_FILE"
			awk '/Ping/ { print $2 }' "$CACHE_FILE"
			;;
		-f|--force)
			rm -rf "$LOCK_FILE"
			run_speedtest
			;;
		-h|--help)
			display_help
			;;
		*)
			run_speedtest
			;;
	esac
elif [ $# -eq 2 ]
then
	if [ $1 = "-l" ]
	then
		run_speedtest "$2"
	fi
elif [ $# -eq 3 ]
then
	if [ $2 = "-l" ]
	then
		case "$1" in
			-c|--cached)
				check_cache_exist "$CACHE_FILE"_"$3"
				cat "$CACHE_FILE"_"$3"
				;;
			-u|--upload)
				check_cache_exist "$CACHE_FILE"_"$3"
				awk '/Upload/ { print $2 }' "$CACHE_FILE"_"$3"
				;;
			-d|--download)
				check_cache_exist "$CACHE_FILE"_"$3"
				awk '/Download/ { print $2 }' "$CACHE_FILE"_"$3"
				;;
			-p|--ping)
				check_cache_exist "$CACHE_FILE"_"$3"
				awk '/Ping/ { print $2 }' "$CACHE_FILE"_"$3"
				;;
		esac
	fi
fi

#!/bin/bash

function help() {
	echo "Launches a dockerized version of the Enigma Discovery network."
	echo
	echo "Usage:"
	echo "	$0 [-h] [-s] [-q]"
	echo
	echo "Options:"
	echo "  -h    Show this help."
	echo "  -q    Stops Enigma Docker Network and removes containers."
	echo "  -s    Run in Simulation mode."
}

function check_config() {
	if [ ! -f .env ]; then
        echo 'Creating .env file from template'
        cp .env-template .env
	fi
}

check_config

ARGF="-f docker-compose.yml"

# By default we run in HW mode, which can be overriden through option below
sed -e 's/SGX_MODE=.*/SGX_MODE=HW/g' .env > .env.tmp && mv .env.tmp .env

while getopts ":hqs" opt; do
	case $opt in
		h) help 
		   exit 0;;
		q) docker-compose down
		   exit 0;;
		s) SIMUL=True
		   sed -e 's/SGX_MODE=.*/SGX_MODE=SW/g' .env > .env.tmp && mv .env.tmp .env;
		   echo "Running in SGX Simulation mode."
	esac
done

if [ ! $SIMUL ]; then
	if [ ! -c /dev/isgx ]; then
		echo "Error: SGX driver not found. Run in simulation mode instead with:"
		echo "$0 $@ -s"
		exit 1
	fi
	ARGF="$ARGF -f docker-compose.hw.yml"
fi

docker-compose $ARGF up
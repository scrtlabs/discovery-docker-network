#!/bin/bash

if [ -z ${NODES+x} ]; then 
	echo "Environment variable NODES is not set, defaulting to 1."
	NODES=1
else
	if [ $NODES -gt 9 ]; then
		echo "NODES is set too large, reverting to the maximum 9 allowed."
		NODES=9
	else
		echo "NODES is set to $NODES"
	fi
fi

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

NODES=$NODES docker-compose $ARGF up --scale core=$NODES --scale p2p=$NODES 
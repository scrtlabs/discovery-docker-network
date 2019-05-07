#!/bin/bash

function init() {
	# Get the folder where the script is located
	SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

	# cd into that folder to reference folders relative to it
	pushd $SELFDIR > /dev/null 2>&1

	# Load environment variables from file
	source .env

	# Check SGX_MODE and inform the user
	if [ "$SGX_MODE" = "HW" ]; then
		echo "Running in Hardware Mode, as per SGX_MODE=HW in .env file."
	elif [ "$SGX_MODE" = "SW" ]; then
		echo "Running in Simulation Mode, as per SGX_MODE=SW in .env file."
	else
		echo "SGX_MODE not set to either HW or SW in .env file. Exiting..."
		exit 1
	fi

	# Check NODES and set within the allowed values 0 < NODES < 10
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
}

function help() {
	echo "Launches a dockerized version of the Enigma Discovery network."
	echo
	echo "Usage:"
	echo "	$0 [-h] [-q]"
	echo
	echo "Options:"
	echo "  -h    Show this help."
	echo "  -q    Stops Enigma Docker Network and removes containers."
}

function check_config() {
	if [ ! -f .env ]; then
        echo 'Creating .env file from template'
        cp .env-template .env
	fi
}

check_config
init

ARGF="-f docker-compose.yml"
if [ -f docker-compose.vol.yml ]; then
	ARGF="$ARGF -f docker-compose.vol.yml"
	echo 'Mounting volumes from docker-compose.vol.yml'
fi

while getopts ":hqs" opt; do
	case $opt in
		h) help 
		   exit 0;;
		q) docker-compose down
		   exit 0;;
	esac
done

if [ "$SGX_MODE" = "HW" ]; then
	if [ ! -c /dev/isgx ]; then
		echo "Error: SGX driver not found. Run in simulation mode instead with:"
		echo "$0 $@ -s"
		exit 1
	fi
	ARGF="$ARGF -f docker-compose.hw.yml"
fi

NODES=$NODES docker-compose $ARGF up --scale core=$NODES --scale p2p=$NODES 
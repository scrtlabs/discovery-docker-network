#!/bin/bash

while true; do
	curl -s -m 1 enigma_core_1:5552 >/dev/null 2>&1
	if [  $? -eq 28 ] ; then
		break
	fi
	echo "$HOSTNAME: Waiting for enigma_core_1..."
	sleep 10
done
echo "enigma_core_1 is ready!"

echo "Waiting for contracts to be deployed..."
until curl -s -m 1 contract:8081 >/dev/null 2>&1; do sleep 5; done

ENIGMACONTRACT="$(curl -s http://contract:8081)"
echo "Enigma Contract Address is : $ENIGMACONTRACT"

IP=$(getent hosts enigma_p2p-proxy_1 | awk '{ print $1 }')
CORE=$(getent hosts enigma_core_1 | awk '{ print $1 }')
CONTRACT=$(getent hosts enigma_contract_1 | awk '{ print $1 }')
cd enigma-p2p/src/cli && node cli_app.js -b /ip4/$IP/tcp/10300/ipfs/QmcrQZ6RJdpYuGvZqD5QEHAv6qX4BrQLJLQPQUrTrzdcgm -n peer1 --core $CORE:5552 --ethereum-websocket-provider ws://$CONTRACT:9545 --ethereum-contract-address $ENIGMACONTRACT

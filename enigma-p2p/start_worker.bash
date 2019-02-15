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

echo "Waiting for Principal Node to start..."
until curl -s -m 1 enigma_principal_1:3040 >/dev/null 2>&1; do sleep 2; done

ENIGMACONTRACT="$(curl -s http://contract:8081)"
echo "Enigma Contract Address is : $ENIGMACONTRACT"

IP=$(getent hosts enigma_p2p-proxy_1 | awk '{ print $1 }')
CORE=$(getent hosts enigma_core_1 | awk '{ print $1 }')
CONTRACT=$(getent hosts enigma_contract_1 | awk '{ print $1 }')
PRINCIPAL="http://$(getent hosts enigma_principal_1 | awk '{ print $1 }'):3040"
cd enigma-p2p/src/cli && node cli_app.js -b /ip4/$IP/tcp/10300/ipfs/QmcrQZ6RJdpYuGvZqD5QEHAv6qX4BrQLJLQPQUrTrzdcgm -n peer1 --core $CORE:5552 --ethereum-websocket-provider ws://$CONTRACT:9545 --ethereum-contract-address $ENIGMACONTRACT --proxy 3346 --random-db --principal-node $PRINCIPAL
# the proxy start for no other reason than to be able to know when the node starts

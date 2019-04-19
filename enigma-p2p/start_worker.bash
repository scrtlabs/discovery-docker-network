#!/bin/bash

# Give time for other containers to start
sleep 5

# Environment variable NETWORK is set through docker-compose.yml

# There is no direct way to know which hostname we are other than 'p2p'
# but we know our IP, and we query through all possible until we find a match
IP=$(getent hosts p2p | awk '{ print $1 }')
for i in {1..10}
do
	if [ $(getent hosts ${NETWORK}_p2p_$i | awk '{ print $1 }') == $IP ]; then
		INDEX=$i
		CORE=$(getent hosts ${NETWORK}_core_${INDEX} | awk '{ print $1 }')
		break
	fi
done

while true; do
	curl -s -m 1 ${NETWORK}_core_${INDEX}:5552 >/dev/null 2>&1
	if [  $? -eq 28 ] ; then
		break
	fi
	echo "${HOSTNAME}_${INDEX}: Waiting for core_${INDEX}..."
	sleep 10
done
echo "core_${INDEX} is ready!"

echo "Waiting for Principal Node to start..."
until curl -s -m 1 principal:3040 >/dev/null 2>&1; do sleep 2; done

ENIGMACONTRACT="$(curl -s http://contract:8081)"
echo "Enigma Contract Address is : $ENIGMACONTRACT"

CONTRACT=$(getent hosts contract | awk '{ print $1 }')
PRINCIPAL="http://$(getent hosts principal | awk '{ print $1 }'):3040"

if [ $INDEX == 1 ]; then
	cd enigma-p2p/src/cli && node cli_app.js -i B1 -b B1 -p B1 --core $CORE:5552 --ethereum-websocket-provider ws://$CONTRACT:9545 --ethereum-contract-address $ENIGMACONTRACT --proxy 3346 --random-db --principal-node $PRINCIPAL; bash
else
	BOOTSTRAP=$(getent hosts ${NETWORK}_p2p_1 | awk '{ print $1 }')
	cd enigma-p2p/src/cli && node cli_app.js -b /ip4/$BOOTSTRAP/tcp/10300/ipfs/QmcrQZ6RJdpYuGvZqD5QEHAv6qX4BrQLJLQPQUrTrzdcgm -n peer1 --core $CORE:5552 --ethereum-websocket-provider ws://$CONTRACT:9545 --ethereum-contract-address $ENIGMACONTRACT --proxy 3346 --random-db --principal-node $PRINCIPAL; bash
fi

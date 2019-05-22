#!/bin/bash

# Give time for other containers to start
sleep 5

# Environment variable NETWORK is set through docker-compose.yml

eth_accounts=(
	'0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1'
	'0xffcf8fdee72ac11b5c542428b35eef5769c409f0'
	'0x22d491bde2303f2f43325b2108d26f1eaba1e32b'
	'0xe11ba2b4d45eaed5996cd0823791e0c93114882d'
	'0xd03ea8624c8c5987235048901fb614fdca89b117'
	'0x95ced938f7991cd0dfcb48f0a06a40fa1af46ebc'
	'0x3e5e9111ae8eb78fe1cc3bb8915d5d461f3ef9a9'
	'0x28a8746e75304c0780e011bed21c72cd78cd535e'
	'0xaca94ef8bd5ffee41947b4585a84bda5a3d3da6e'
	'0x1df62f291b2e969fb0849d99d9ce41e2f137006e'
)

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

echo "Waiting for the Key Management node to start..."
until curl -s -m 1 km:3040 >/dev/null 2>&1; do sleep 2; done

while [ -z $ENIGMACONTRACT ]; do
	ENIGMACONTRACT="$(curl -s http://contract:8081)"
done
echo "Enigma Contract Address is : $ENIGMACONTRACT"

CONTRACT=$(getent hosts contract | awk '{ print $1 }')
KM="http://$(getent hosts km | awk '{ print $1 }'):3040"

echo "Starting ${NETWORK}_p2p_${INDEX} with Ethereum Address: ${eth_accounts[$INDEX - 1]} and the following command:"
if [ $INDEX == 1 ]; then
	P2P_CMD="node cli_app.js -i B1 -b B1 -p B1 --core $CORE:5552 --ethereum-websocket-provider ws://$CONTRACT:9545 --ethereum-contract-address $ENIGMACONTRACT --proxy 3346 --random-db --principal-node $KM --ethereum-address ${eth_accounts[$INDEX - 1]} --auto-init"
	echo $P2P_CMD
	cd enigma-p2p/src/cli && $P2P_CMD; bash
else
	BOOTSTRAP=$(getent hosts ${NETWORK}_p2p_1 | awk '{ print $1 }')
	P2P_CMD="node cli_app.js -b /ip4/$BOOTSTRAP/tcp/10300/ipfs/QmcrQZ6RJdpYuGvZqD5QEHAv6qX4BrQLJLQPQUrTrzdcgm -n peer1 --core $CORE:5552 --ethereum-websocket-provider ws://$CONTRACT:9545 --ethereum-contract-address $ENIGMACONTRACT --proxy 3346 --random-db --principal-node $KM --ethereum-address ${eth_accounts[$INDEX - 1]} --auto-init"
	echo $P2P_CMD
	cd enigma-p2p/src/cli && $P2P_CMD; bash
fi

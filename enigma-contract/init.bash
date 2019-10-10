#!/bin/bash

# Environment variable NETWORK is set through docker-compose.yml

# Check if $NODES is set
if [ -z ${NODES+x} ]; then
	NODES=1
fi

cd /root/enigma-contract/enigma-js

echo "Waiting for ${NETWORK}_p2p_1..."
until curl -s -m 1 ${NETWORK}_p2p_1:3346; do sleep 3; done

echo "Waiting for ${NETWORK}_p2p_1 to register..."
sleep $((8*$NODES))

# if we initialized the enigma_proxy to a fixed IP address then take it from there,
# otherwise, take it from getent.
if [ -z ${ENIGMA_PROXY_IP} ]; then
  ENIGMA_PROXY_IP=$(getent hosts ${NETWORK}_p2p_1 | awk '{ print $1 }')
fi

# same as to the ip address of the contract
if [ -z ${ENIGMA_CONTRACT_IP} ]; then
  ENIGMA_CONTRACT_IP=$(getent hosts contract | awk '{ print $1 }')
fi

for filename in test/integrationTests/template.*; do
	sed -e "s_http://[localhost|.0-9]*:3346_http://$ENIGMA_PROXY_IP:3346_" $filename > $(echo $filename | sed "s/template\.\(.*\).js/\1.spec.js/")
  sed -i "s_http://[localhost|.0-9]*:9545_http://$ENIGMA_CONTRACT_IP:9545_" $(echo $filename | sed "s/template\.\(.*\).js/\1.spec.js/")
done

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

proxy=$(getent hosts ${NETWORK}_p2p_1 | awk '{ print $1 }')
contract=$(getent hosts contract | awk '{ print $1 }')

for filename in test/integrationTests/template.*; do 
	sed -e "s_http://[localhost|.0-9]*:3346_http://$proxy:3346_" $filename > $(echo $filename | sed "s/template\.\(.*\).js/\1.spec.js/")
    sed -i "s_http://[localhost|.0-9]*:9545_http://$contract:9545_" $(echo $filename | sed "s/template\.\(.*\).js/\1.spec.js/")
done

#!/bin/bash

# Environment variable NETWORK is set through docker-compose.yml

cd /root/enigma-contract/enigma-js

echo "Waiting for ${NETWORK}_p2p_1..."
until curl -s -m 1 ${NETWORK}_p2p_1:3346; do sleep 3; done

echo "Waiting for ${NETWORK}_p2p_1 to register..."
sleep 5

proxy=$(getent hosts ${NETWORK}_p2p_1 | awk '{ print $1 }')
contract=$(getent hosts contract | awk '{ print $1 }')
contractaddress=$(curl -s http://contract:8081)
tokenaddress=$(curl -s http://contract:8082)

for filename in test/integrationTests/template.*; do 
	sed -e "s_http://[localhost|.0-9]*:3346_http://$proxy:3346_" $filename > $(echo $filename | sed "s/template\.\(.*\).js/\1.spec.js/")
    sed -i "s_http://[localhost|.0-9]*:9545_http://$contract:9545_" $(echo $filename | sed "s/template\.\(.*\).js/\1.spec.js/")
	sed -i "s/EnigmaContract.networks\['4447'\].address/'$contractaddress'/" $(echo $filename | sed "s/template\.\(.*\).js/\1.spec.js/")
	sed -i "s/EnigmaTokenContract.networks\['4447'\].address/'$tokenaddress'/" $(echo $filename | sed "s/template\.\(.*\).js/\1.spec.js/")
done

test/integrationTests/runTests.bash

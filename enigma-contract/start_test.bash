#!/bin/bash
cd /root/enigma-contract/enigma-js

echo "Waiting for p2p-worker..."
until curl -s -m 1 p2p-worker:3346; do sleep 5; done

echo "Waiting for p2p-worker to register..."
sleep 7

proxy=$(getent hosts p2p-proxy | awk '{ print $1 }')
sed -i "s_http://[localhost|.0-9]*:3346_http://$proxy:3346_" test/integrationTests/Enigma-integration.spec.js

contract=$(getent hosts contract | awk '{ print $1 }')
sed -i "s_http://[localhost|.0-9]*:9545_http://$contract:9545_" test/integrationTests/Enigma-integration.spec.js

contractaddress=$(curl -s http://contract:8081)
tokenaddress=$(curl -s http://contract:8082)
sed -i "s/EnigmaContract.networks\['4447'\].address/'$contractaddress'/" test/integrationTests/Enigma-integration.spec.js
sed -i "s/EnigmaTokenContract.networks\['4447'\].address/'$tokenaddress'/" test/integrationTests/Enigma-integration.spec.js

yarn test:integration

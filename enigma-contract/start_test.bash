#!/bin/bash
cd /root/enigma-contract/enigma-js

echo "Waiting for enigma_p2p-worker_1..."
until curl -s -m 1 p2p-worker:3346; do sleep 5; done

echo "Waiting for p2p-worker to register..."
sleep 7

proxy=$(getent hosts enigma_p2p-proxy_1 | awk '{ print $1 }')
sed -i "s_http://localhost:3346_http://$proxy:3346_" test/integrationTests/Enigma-integration.spec.js

contract=$(getent hosts enigma_contract_1 | awk '{ print $1 }')
sed -i "s_http://localhost:9545_http://$contract:9545_" test/integrationTests/Enigma-integration.spec.js

contractaddress=$(curl -s http://enigma_contract_1:8081)
tokenaddress=$(curl -s http://enigma_contract_1:8082)
sed -i "s/EnigmaContract.networks\['4447'\].address/'$contractaddress'/" test/integrationTests/Enigma-integration.spec.js
sed -i "s/EnigmaTokenContract.networks\['4447'\].address/'$tokenaddress'/" test/integrationTests/Enigma-integration.spec.js

yarn test:integration

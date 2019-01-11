#!/bin/bash
cd /root/enigma-contract/enigma-js

while true; do
	curl -s -m 1 http://enigma_p2p-worker_1:8081 > /dev/null
	if [[  $? -eq 0 ]] ; then
		break
	fi
	echo "$HOSTNAME: Waiting for enigma_p2p-worker_1..."
	sleep 10
done
echo "enigma_p2p-worker_1 is ready!"

signKey=$(curl -s http://enigma_p2p-worker_1:8081)
echo "Core signKey is $signKey"
sed -i "s/workerAddress=.*$/workerAddress='$signKey'/" test/integrationTests/Enigma-integration.spec.js 

proxy=$(getent hosts enigma_p2p-proxy_1 | awk '{ print $1 }')
sed -i "s_http://localhost:3346_http://$proxy:3346_" test/integrationTests/Enigma-integration.spec.js 

contract=$(getent hosts enigma_contract_1 | awk '{ print $1 }')
sed -i "s_http://localhost:9545_http://$contract:9545_" test/integrationTests/Enigma-integration.spec.js 

yarn test:integration

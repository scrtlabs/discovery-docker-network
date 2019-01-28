#!/bin/bash

while true; do
	curl -s -m 1 enigma_core_1:5552
	if [  $? -eq 28 ] ; then
		break
	fi
	echo "$HOSTNAME: Waiting for enigma_core_1..."
	sleep 10
done
echo "enigma_core_1 is ready!"

IP=$(getent hosts enigma_p2p-proxy_1 | awk '{ print $1 }')
CORE=$(getent hosts enigma_core_1 | awk '{ print $1 }') 
cd enigma-p2p/src/cli && node cli_app.js -b /ip4/$IP/tcp/10300/ipfs/QmcrQZ6RJdpYuGvZqD5QEHAv6qX4BrQLJLQPQUrTrzdcgm -n peer1 --core $CORE:5552 &
while [ ! -f /root/enigma-p2p/src/cli/signKey.txt ]
do
  sleep 1
done
cd /root && ./simpleHTTP.bash

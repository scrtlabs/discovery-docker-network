#!/bin/bash
while true; do 
	echo -ne "HTTP/1.1 200 OK\r\nContent-Length:$(wc -c < /root/enigma-p2p/src/cli/signKey.txt)\r\nAccess-Control-Allow-Origin: *\r\n\r\n$(cat /root/enigma-p2p/src/cli/signKey.txt)" | nc -l -p 8081 -q 1
done

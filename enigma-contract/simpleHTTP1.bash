while true; do 
	echo -ne "HTTP/1.1 200 OK\r\nContent-Length:$(wc -c < ~/.enigma/enigmacontract.txt)\r\nAccess-Control-Allow-Origin: *\r\n\r\n$(cat ~/.enigma/enigmacontract.txt)" | nc -l -p 8081 -q 1
done


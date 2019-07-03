#!/bin/bash
rm -f /root/.enigma/principal-sign-addr.txt ./enigma-contract/enigmacontract.txt ./enigmacontract/enigmatokencontract.txt
sudo apt-get update && sudo apt install awscli -y
until [! $(aws s3 ls s3://enigma-protocol-shared-storage/enigma | grep principal-sign-addr.txt) ];do sleep 1; done;

aws s3 sync s3://enigma-protocol-shared-storage/enigma /home/ubuntu/.enigma
ganache-cli -d -p 9545 -i 4447 -h 0.0.0.0 &
sleep 5
cd enigma-contract
truffle compile
truffle migrate --reset network development
cp build/contracts/Enigma.json build/contracts/EnigmaMock.json
~/simpleHTTP1.bash &
~/simpleHTTP2.bash &

#!/bin/bash
rm -f /root/.enigma/principal-sign-addr.txt ./enigma-contract/enigmacontract.txt ./enigmacontract/enigmatokencontract.txt

sudo apt-get update >/dev/null 2>&1 && sudo apt install awscli -y >/dev/null 2>&1
aws s3 sync s3://enigma-protocol-shared-storage/contracts/ /root/enigma-contract/build/contracts
while ! aws s3 ls s3://enigma-protocol-shared-storage/enigma/ | grep principal-sign-addr.txt; do sleep 1;done;
aws s3 sync s3://enigma-protocol-shared-storage/enigma /root/.enigma

ganache-cli -d -p 9545 -i 4447 -h 0.0.0.0 &
sleep 5
cd enigma-contract
truffle compile
truffle migrate --reset network development
cp build/contracts/Enigma.json build/contracts/EnigmaMock.json

aws s3 sync /root/.enigma/ s3://enigma-protocol-shared-storage/enigma/
aws s3 sync /root/enigma-contract/build/contracts s3://enigma-protocol-shared-storage/contracts/
~/simpleHTTP1.bash &
~/simpleHTTP2.bash &

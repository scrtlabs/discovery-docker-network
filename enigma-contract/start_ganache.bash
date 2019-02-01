#!/bin/bash
ganache-cli -d -p 9545 -i 4447 -h 0.0.0.0 &
sleep 5
cd enigma-contract
truffle compile
truffle migrate --reset network development
cp build/contracts/Enigma.json build/contracts/EnigmaMock.json
~/simpleHTTP1.bash &
~/simpleHTTP2.bash &

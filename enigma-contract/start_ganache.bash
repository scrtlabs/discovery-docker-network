#!/bin/bash
myIp=$(getent hosts enigma_contract | awk '{ print $1 }')
ganache-cli -p 9545 -i 4447 -h $myIp

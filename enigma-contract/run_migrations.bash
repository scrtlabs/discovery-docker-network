#!/bin/bash
cd enigma-contract
truffle compile
truffle migrate --reset --network development

#!/bin/bash

./init.bash
cd enigma-contract/enigma-js/test/integrationTests/ && yarn test:integration 01_init.spec.js

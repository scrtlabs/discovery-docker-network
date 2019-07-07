#!/bin/bash
sudo apt-get update >/dev/null 2>&1 && sudo apt install awscli -y >/dev/null 2>&1
aws s3 sync s3://enigma-protocol-shared-storage/contracts/ /root/enigma-contract/build/contracts
./init.bash
cd enigma-contract/enigma-js && test/integrationTests/runTests.bash

#!/bin/bash
/opt/intel/libsgx-enclave-common/aesm/aesm_service &
sleep 5 # give time to aesm_service to start

contract=$(getent hosts enigma_contract_1 | awk '{ print $1 }')
sed -i "s_http://[localhost|.0-9]*:9545_http://$contract:9545_" principal_test_config.json

cp principal_test_config.json /root/enigma-core/enigma-principal/app/tests/principal_node/config

cd /root/enigma-core/enigma-principal/bin
RUST_BACKTRACE=1 ./enigma-principal-app

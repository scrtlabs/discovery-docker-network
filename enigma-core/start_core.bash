#!/bin/bash
/opt/intel/libsgx-enclave-common/aesm/aesm_service &
sleep 5 # give time to aesm_service to start
cd /root/enigma-core/enigma-core/app
RUST_BACKTRACE=1 ./target/release/enigma-core-app

#!/bin/bash
/opt/intel/libsgx-enclave-common/aesm/aesm_service &
sleep 5 # give time to aesm_service to start
cd /root/enigma-core/enigma-core/app
. /opt/sgxsdk/environment && . /root/.cargo/env && RUST_BACKTRACE=1 ./target/release/enigma-core-app -vvv --debug-stdout

#!/bin/bash
cd /root/enigma-core/enigma-core/app
sed -i '/\#\[ignore\]/d' src/networking/ipc_listener.rs
. /opt/sgxsdk/environment && . /root/.cargo/env && SGX_MODE=SW cargo test test_real_listener

#!/bin/bash
cd /root/enigma-core/enigma-core/app
. /opt/sgxsdk/environment && . /root/.cargo/env && cargo build
./target/release/enigma-core-app

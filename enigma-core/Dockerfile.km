FROM enigmampc/enigma-core:latest as runtime

LABEL maintainer='info@enigma.co'

WORKDIR /root

ARG GIT_BRANCH_CORE
RUN git clone -b $GIT_BRANCH_CORE --single-branch https://github.com/enigmampc/enigma-core.git

WORKDIR /root/enigma-core/enigma-principal
RUN . /opt/sgxsdk/environment && . /root/.cargo/env && make full-clean

ARG SGX_MODE

RUN . /opt/sgxsdk/environment && . /root/.cargo/env && SGX_MODE=$SGX_MODE RUSTFLAGS=-Awarnings RUST_BACKTRACE=1 make DEBUG=1 || \
    echo "\n\n**** This is a known error. Ignore for now. Will succeed upon retry ***\n" && \
    rm -rf /root/.cargo/git/checkouts/rust-sgx-sdk-fc8771c5c45bde9a/212d9f4/xargo && \
    SGX_MODE=$SGX_MODE RUSTFLAGS=-Awarnings RUST_BACKTRACE=1 make DEBUG=1 || true

WORKDIR /root
COPY start_km.bash .
COPY principal_test_config.json .

ENTRYPOINT ["/usr/bin/env"]
CMD ["/bin/bash","-c","./start_km.bash; bash"]

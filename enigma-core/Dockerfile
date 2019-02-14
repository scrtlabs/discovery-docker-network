########################################################################
# BUILD STAGE 1
# inherit the baidu sdk image
FROM baiduxlab/sgx-rust:1804 as builder

# Required for private repos, will be removed when repo is public
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa
RUN ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

WORKDIR /root

ARG GIT_BRANCH_CORE
RUN git clone -b $GIT_BRANCH_CORE --single-branch git@github.com:enigmampc/enigma-core-internal.git
RUN mv enigma-core-internal enigma-core

RUN rm -f /root/.ssh/id_rsa

########################################################################
# BUILD STAGE 2 - copy the repo dir into a fresh runtime image
FROM baiduxlab/sgx-rust:1804 as runtime
COPY --from=builder /root/enigma-core /root/enigma-core

# dependency for https://github.com/erickt/rust-zmq
RUN apt-get update && \
    apt-get install -y --no-install-recommends libzmq3-dev clang \
    && rm -rf /var/lib/apt/lists/*

RUN rm -rf /root/sgx
RUN git clone https://github.com/baidu/rust-sgx-sdk.git sgx -b v1.0.4

RUN /root/.cargo/bin/rustup target add wasm32-unknown-unknown && rm -rf /root/.cargo/registry && rm -rf /root/.cargo/git
RUN echo '/opt/intel/libsgx-enclave-common/aesm/aesm_service &' >> /root/.bashrc

WORKDIR /root/enigma-core/enigma-core
RUN . /opt/sgxsdk/environment && . /root/.cargo/env && make full-clean
ARG SGX_MODE

RUN . /opt/sgxsdk/environment && . /root/.cargo/env && SGX_MODE=$SGX_MODE RUSTFLAGS=-Awarnings make JOBS=4 || \
    echo "\n\n**** This is a known error. Ignore for now. Will succeed upon retry ***\n" && \
    rm -rf /root/.cargo/git/checkouts/rust-sgx-sdk-fc8771c5c45bde9a/212d9f4/xargo && . /opt/sgxsdk/environment && . /root/.cargo/env && SGX_MODE=$SGX_MODE RUSTFLAGS=-Awarnings make JOBS=4 || true

WORKDIR /root/enigma-core/enigma-core/app
RUN . /opt/sgxsdk/environment && . /root/.cargo/env && SGX_MODE=$SGX_MODE cargo build

WORKDIR /root
COPY start_core.bash .
RUN mkdir /root/.enigma

ENTRYPOINT ["/usr/bin/env"]
CMD ["/bin/bash","-c","./start_core.bash; bash"]

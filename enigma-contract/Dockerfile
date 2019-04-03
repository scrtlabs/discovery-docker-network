FROM node:11 as runtime

LABEL maintainer='info@enigma.co'

WORKDIR /root

ARG GIT_BRANCH_CONTRACT
RUN git clone -b $GIT_BRANCH_CONTRACT --single-branch https://github.com/enigmampc/enigma-contract.git

RUN apt-get update && apt-get install -y sudo net-tools netcat

WORKDIR /root/enigma-contract

RUN yarn install
RUN yarn global add ganache-cli truffle
RUN cd enigma-js && yarn install

WORKDIR /root
COPY start_test.bash .
COPY start_ganache.bash .
COPY simpleHTTP1.bash .
COPY simpleHTTP2.bash .
RUN mkdir -p /root/.enigma

ARG SGX_MODE
ENV SGX_MODE=$SGX_MODE

ENTRYPOINT ["/usr/bin/env"]
CMD ["/bin/bash"]

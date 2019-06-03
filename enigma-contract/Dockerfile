FROM node:11 as runtime

LABEL maintainer='info@enigma.co'

WORKDIR /root

ARG GIT_BRANCH_CONTRACT
RUN git clone -b $GIT_BRANCH_CONTRACT --single-branch https://github.com/enigmampc/enigma-contract.git

RUN apt-get update && apt-get install -y sudo net-tools netcat build-essential nano
RUN yarn global add ganache-cli truffle

WORKDIR /root/enigma-contract

RUN npm install
RUN cd enigma-js && yarn install

WORKDIR /root
COPY simpleHTTP1.bash .
COPY simpleHTTP2.bash .
COPY init.bash .
COPY start_test.bash .
COPY login_workers.bash .
COPY launch_ganache.bash .

RUN mkdir -p /root/.enigma

ENTRYPOINT ["/usr/bin/env"]
CMD ["/bin/bash"]

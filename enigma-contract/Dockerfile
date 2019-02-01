########################################################################	
# BUILD STAGE 1 
FROM node:10 as builder

# Required for private repos, will be removed when repo is public	
ARG SSH_PRIVATE_KEY	
RUN mkdir /root/.ssh/	
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa	
RUN chmod 600 /root/.ssh/id_rsa	
RUN ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

WORKDIR /root

ARG GIT_BRANCH_CONTRACT
RUN git clone -b $GIT_BRANCH_CONTRACT --single-branch git@github.com:enigmampc/enigma-contract-internal.git

RUN rm -f /root/.ssh/id_rsa

########################################################################	
# BUILD STAGE 2 - copy the repo dir into a fresh runtime image
FROM node:10 as runtime
COPY --from=builder /root/enigma-contract-internal /root/enigma-contract

LABEL maintainer='info@enigma.co'

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

ENTRYPOINT ["/usr/bin/env"]
CMD ["/bin/bash"]

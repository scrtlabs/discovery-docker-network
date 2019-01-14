# discovery-integration-tests

[![Build Status](https://travis-ci.com/enigmampc/discovery-integration-tests.svg?token=cNBBjbVVEGszuAJUokFT&branch=develop)](https://travis-ci.com/enigmampc/discovery-integration-tests)

This repository includes a suite of Integration Tests across multiple repositories for the Discovery release of the Enigma Network.
Currently integrates with the following repositories, and their corresponding branches (eventually becoming master):

| Repo   | Branch | Build |
|--------|--------|-------|
| [enigma-contract-internal](https://github.com/enigmampc/enigma-contract-internal/tree/integration-tests) | integration-tests | [![Build Status](https://travis-ci.com/enigmampc/enigma-contract-internal.svg?token=cNBBjbVVEGszuAJUokFT&branch=integration-tests)](https://travis-ci.com/enigmampc/enigma-contract-internal) |
| [enigma-p2p](https://github.com/enigmampc/enigma-p2p/tree/jsonrpc-integration) | jsonrpc-integration|[![Build Status](https://travis-ci.com/enigmampc/enigma-p2p.svg?token=cNBBjbVVEGszuAJUokFT&branch=jsonrpc-integration)](https://travis-ci.com/enigmampc/enigma-p2p) |
| [enigma-core-internal](https://github.com/enigmampc/enigma-core-internal/tree/main) | develop | <img src="https://drone.enigma.co/api/badges/enigmampc/enigma-core-internal/status.svg?branch=develop"/> |

The following is a list of the Integration Tests planned, and their status:

| Status | Test |
|--------|------|
| Pass   | Client requests encryption key from worker |
|        | Register a new worker node in the Enigma contract |
|        | Deploy a new contract |
|        | Compute Task |

## Running the tests

1. Create your `env` file from the template. No need to change any environment variables. Lines 6-9 can be disregarded as they are not currently used.

    ```
    $ cp .env-template .env
    ```

2. Build the docker images. Because the build fetches private repositories, you need to provide your private Github SSH key (for example `~/.ssh/id_rsa`). The first time, this command can take between one or two hours. It will build and run in SGX simulation mode (Hardware mode not supported for this repo, although is fully supported in the core repo).

    ```
    $ docker-compose build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
    ```

3. Launch the docker network

    ```
    $ docker-compose up
    ```

4. In a separate terminal, run the integration tests:

    ```
    $ docker-compose run client ./start_test.bash
    ```

# discovery-integration-tests

| Service | Master | Develop |
|---------|--------|---------|
| Drone (SGX_MODE=HW) | <img src="https://drone.enigma.co/api/badges/enigmampc/discovery-integration-tests/status.svg?branch=master"/> | <img src="https://drone.enigma.co/api/badges/enigmampc/discovery-integration-tests/status.svg?branch=develop"/> | 
| Travis (SGX_MODE=SW) | [![Build Status](https://travis-ci.com/enigmampc/discovery-integration-tests.svg?token=cNBBjbVVEGszuAJUokFT&branch=master)](https://travis-ci.com/enigmampc/discovery-integration-tests) (Disabled) | [![Build Status](https://travis-ci.com/enigmampc/discovery-integration-tests.svg?token=cNBBjbVVEGszuAJUokFT&branch=develop)](https://travis-ci.com/enigmampc/discovery-integration-tests) (Disabled)

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
| Pass   | Register a new worker node in the Enigma contract |
| Pass   | Client requests encryption key from worker |
|        | Deploy a new contract |
|        | Compute Task |

## Running the tests

1. Create your `env` file from the template. No need to change any environment variables. Lines 7-10 can be disregarded as they are not currently used.

    ```
    $ cp .env-template .env
    ```

2. Launch the docker network (by default runs in SGX Hardware mode, see next section for running in Simulation mode).

    ```
    $ ./launch.bash
    ```

3. ... and then, run the integration tests:

    ```
    $ docker-compose run client ./start_test.bash
    ```
    
## Simulation mode

The docker network can run both in SGX Hardware and Software (Simulation) modes. It defaults to SGX Hardware mode. In order to run in simulation mode, you need to do two things:

1. Edit `.env` and change `SGX_MODE=SW`, and then build the docker images (Step #2 above).
2. Launch the network with `./launch.bash -s`

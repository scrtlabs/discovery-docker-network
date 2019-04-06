# discovery-integration-tests

| Service | Master | Develop |
|---------|--------|---------|
| Drone (SGX_MODE=HW) | [<img src="https://drone.enigma.co/api/badges/enigmampc/discovery-integration-tests/status.svg?branch=master"/>](https://drone.enigma.co/enigmampc/discovery-integration-tests) | [<img src="https://drone.enigma.co/api/badges/enigmampc/discovery-integration-tests/status.svg?branch=develop"/>](https://drone.enigma.co/enigmampc/discovery-integration-tests) | 
| Travis (SGX_MODE=SW) | [![Build Status](https://travis-ci.com/enigmampc/discovery-integration-tests.svg?token=cNBBjbVVEGszuAJUokFT&branch=master)](https://travis-ci.com/enigmampc/discovery-integration-tests) | [![Build Status](https://travis-ci.com/enigmampc/discovery-integration-tests.svg?token=cNBBjbVVEGszuAJUokFT&branch=develop)](https://travis-ci.com/enigmampc/discovery-integration-tests) |

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
|   ✅   | Register a new worker node in the Enigma contract |
|   ✅   | Client requests encryption key from worker |
|   ✅   | Successful Deployment of a Secret Contract |
|   ✅   | Successful Execution of a Secret Contract |
|        | Successful Execution of a Secret Contract with an Ethereum call |
|        | Successful Execution of successive Secret Contract in different epochs that store and retrieve state, and require successful PTT |
|        | Successful Execution of multiple Secret Contracts deployed on the same network, and assigned to different nodes in successive epochs |
|        | Failed Deployment of Secret Contract - Wrong Encryption Key	|
|   ✅   | Failed Deployment of Secret Contract - Wrong Bytecode |
|        | Failed Execution of Secret Contract - Wrong Encryption Key |
|        | Failed Execution of Secret Contract - Wrong Params |
|        | Failed Execution of Secret Contract - Out of Gas	|
|        | Failed Execution of Secret Contract - Runtime Exception |
|        | Failed Execution of Secret Contract - Wrong worker |
|        | Failed Execution of Secret Contract - Wrong Ethereum Payload |


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

## Building the Docker images

The first time that you launch the network, and the images for each container are not yet available, Docker will build them automatically. 

If you want to manually rebuild them at a later time, you can do so using the following command, which will only pick up local changes, but will not pick up new commits on any of the remote repos it fetches:
```
$ docker-compose build
```

To force a rebuild without using any of the cached previous images (to pick a more recent commit from a remote repo, for example), run:
```
$ docker-compose build --no-cache
```

And to rebuild only the image for one of the containers, use any of the labels that you will find in the `docker-compose.yml`:
```
$ docker-compose build {image_name}
```
where `{image_name}` is one of the following: `contract`, `p2p-proxy`, `p2p-worker`, `client`, `core`, `principal`, and which can be combined with the `--no-cache` option as follows:
```
$ docker-compose build --no-cache {image_name}
```

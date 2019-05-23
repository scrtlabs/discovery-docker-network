# Enigma Discovery Docker Network

| Service | Master | Develop |
|---------|--------|---------|
| Drone (SGX_MODE=HW) | [<img src="https://drone.enigma.co/api/badges/enigmampc/discovery-docker-network/status.svg?branch=master"/>](https://drone.enigma.co/enigmampc/discovery-docker-network) | [<img src="https://drone.enigma.co/api/badges/enigmampc/discovery-docker-network/status.svg?branch=develop"/>](https://drone.enigma.co/enigmampc/discovery-docker-network) | 
| Travis (SGX_MODE=SW) | [![Build Status](https://travis-ci.com/enigmampc/discovery-docker-network.svg?token=cNBBjbVVEGszuAJUokFT&branch=master)](https://travis-ci.com/enigmampc/discovery-docker-network) | [![Build Status](https://travis-ci.com/enigmampc/discovery-docker-network.svg?token=cNBBjbVVEGszuAJUokFT&branch=develop)](https://travis-ci.com/enigmampc/discovery-docker-network) |

This repository provides a Docker network that runs the upcoming Discovery release of the Enigma protocol. It integrates the the following repositories that provide the various components that make up the network: [enigma-contract](https://github.com/enigmampc/enigma-contract), [enigma-core](https://github.com/enigmampc/enigma-core) and [enigma-p2p](https://github.com/enigmampc/enigma-p2p): 

| Repo   | Branch | Build |
|--------|--------|-------|
| [enigma-contract](https://github.com/enigmampc/enigma-contract/tree/develop) | develop | [![Build Status](https://travis-ci.org/enigmampc/enigma-contract.svg?branch=develop)](https://travis-ci.org/enigmampc/enigma-contract) |
| [enigma-p2p](https://github.com/enigmampc/enigma-p2p/tree/jsonrpc-integration) | develop |[![Build Status](https://travis-ci.org/enigmampc/enigma-p2p.svg?branch=develop)](https://travis-ci.org/enigmampc/enigma-p2p) |
| [enigma-core](https://github.com/enigmampc/enigma-core/tree/develop) | develop | <img src="https://drone.enigma.co/api/badges/enigmampc/enigma-core/status.svg?branch=develop"/> |

This repository is configured for Continuous Integration (CI) on two different testing environments: Drone, where SGX runs in hardware mode, and Travis, where SGX runs in simulation mode. The tests include a comprehensive suite of integration tests across the network that cover all [these scenarios](https://github.com/enigmampc/discovery-integration-tests/issues/2). 

## Table of Contents

* [Background](#background)
* [Requirements](#requirements)
* [Installation](#installation)
* [Simulation Mode](#simulation-mode)
* [Troubleshooting](#troubleshooting)
* [Advanced Topics](#advanced-topics)
  * [Building the Docker images](#building-the-docker-images)
  * [Mounting volumes for development](#mounting-volumes-for-development)
  * [Running multiple workers](#running-multiple-workers)
  * [Logging](#logging)
  * [Integration Tests](#integration-tests)


## Background

The Enigma Docker network integrates three different repositories that provide all the various services that make up the network. Each service gets its own container in the network as follows (which match the stanzas in the [docker-compose.yml](https://github.com/enigmampc/discovery-docker-network/blob/develop/docker-compose.yml) that provide the configuration for the Docker network):

- **Contract**: the Enigma contract provides the consensus layer in the network and is the “source of truth” for the state and results of secret computations, mostly in the form of hashes that are used for verification purposes.
- **Enigma.JS Library (client)**: The Enigma Javascript library is the interface to the Enigma network for secret contract developers, and the entry point for dApp users. Once the network is up and running, this is the component that triggers the deployment of secret contracts in the network and triggers the secret computations, later verifying their correct execution.
- **Core**: The code running inside the Trusted Execution Environment (TEE, which is SGX in the case of Intel) is written in Rust, and contains Enigma’s adaptation of WASM that runs the bytecode for secret contract in a Virtual Machine inside the secure hardware. It receives the secret contract inputs encrypted from the user, and encrypts its outputs so that only the user can decrypt them.
- **Peer-to-Peer (p2p)**: Each enclave communicates one-on-one with its networking component, written in Javascript, that provides an interface to the rest of the network and to the contract.
- **Key Management (km) Node**: A special instance of the core code that manages the encryption keys to maintain the state of secret contracts across the network. It responds to requests from other enclaves providing the needed keys to decrypt and re-encrypt the state associated with each secret contract deployed in the network.

There is one more element in the Enigma network that is not part of the Docker network, but it is already live as an online service that Enigma provides. Thus the Docker network requires an active Internet connection to connect to the following service in order for the network to operate properly:

- **Remote Attestation Proxy**: An online  secure web server provided by Enigma as an interface to Intel Remote Attestation Service (IAS), so that anyone can validate that any enclave in the Enigma network runs its code inside a legitimate enclave and runs the code that it is supposed to run and not some other malicious code.

## Requirements

- [Docker](https://docs.docker.com/install/overview/)
- [Docker Compose](https://docs.docker.com/compose/install/) version 1.23.2 or higher. Please be aware that docker introduced a bug in 1.23.0 (also present in 1.23.1) that appended random strings to container names that causes this network configuration to break.

If you want to run SGX in Hardware mode, in the same way it will be run in production, you will also need:

- A host machine with Intel [Software Guard Extensions](https://software.intel.com/en-us/sgx) (SGX) enabled.

  - The [SGX hardware](https://github.com/ayeks/SGX-hardware) repository 
    provides a list of hardware that supports Intel SGX, as well as a simple
    script to check if SGX is enabled on your system.

- A host machine with [Linux SGX driver](https://github.com/intel/linux-sgx-driver) 
  installed (version 2.x recommended). Upon successful installation of the driver ``/dev/isgx`` should be
  present in the system.

However, for development purposes, the Enigma Discovery Docker Network can be run in Simulation (or Software mode), where no specialized hardware is required.

## Installation

To set up a developer environment, you will need to run the Docker network provided in this repo, and mount local copies of the [enigma-contract](https://github.com/enigmampc/enigma-contract) and [enigma-core](https://github.com/enigmampc/enigma-core) repositories to be able to make local changes, and do the actual development of secret contracts that you will subsequently deploy and run on the Docker network.


1. Clone the [enigma-contract](https://github.com/enigmampc/enigma-contract), [enigma-core](https://github.com/enigmampc/enigma-core) and [discovery-docker-network](https://github.com/enigmampc/discovery-docker-network) repositories mentioned above onto your local machine with the following commands:

    ```
    git clone https://github.com/enigmampc/enigma-contract.git
    git clone https://github.com/enigmampc/enigma-core.git
    git clone https://github.com/enigmampc/enigma-docker-network.git
    ```

From within the `discovery-docker-network` directory you have just cloned:

2. Create a `.env` file based off of the `.env-template` file and adjust `SGX_MODE` to equal `SW` (software/simulation) or `HW `(hardware-compatible device) accordingly. Refer to the [Requirements](#requirements) section above for additional information.

3. Refer to the [Mounting volumes for development](#mounting-volumes-for-development) and edit the [docker-compose.yml](https://github.com/enigmampc/discovery-docker-network/blob/develop/docker-compose.yml) file to volume map your local repositories on the relevant containers (`client` and `core`). You can accomplish this by adding a line item to the `volumes` section in the container’s stanza in the following format: `local_folder:folder_in_container`. More specifically:

    For the `client` container, add the following line to the volumes section:

    ```
    - "/local/path/enigma-contract:/root/enigma-contract"
    ```

    where you must replace the `/local/path/enigma-contract` fragment with the absolute path to where you have cloned the `enigma-contract` repository in step 1 above in your local machine.

    For the `core` container, add a volumes section and the core repository mapping:

    ```
    volumes:
      - "/local/path/enigma-core:/root/enigma-core"
    ```
    
    where again you must replace the `/local/path/enigma-core` fragment with the absolute path to where you have cloned the `enigma-core` repository in step 1 above in your local machine.

4. Still within `discovery-docker-network` repo, run:

    ```
    docker-compose build
    ```

    to build all the Docker images needed for the network. You only need to do this step before the first time you launch the network. Depending on the capabilities of your computer, it can take up an hour or more (*Note: the build of `core` and `km` may throw an error that is accounted for, and the build will handle it as needed.*). Refer to the [Building the Docker images](#building-the-docker-images) section, if you need to rebuild the Docker images in the future.

5. Within the `discovery-docker-network`, run `./launch.bash` to launch the Docker network. 

6. Within the `core` repo folder, create a new `lib` Rust project under `examples/eng_wasm_contracts` on the command line with:

    ```
    cd examples/eng_wasm_contracts
    cargo new <project_name> --lib
    ```

    and edit the `Cargo.toml` inside the newly created folder, to add the following sections (so that it resembles one of [the example ones](https://github.com/enigmampc/enigma-core/blob/develop/examples/eng_wasm_contracts/simple_calculator/Cargo.toml)):

    ```
    [dependencies]
    eng-wasm = {path = "../../../eng-wasm"}
    eng-wasm-derive = {path = "../../../eng-wasm/derive"}

    [lib]
    crate-type = ["cdylib"]

    [profile.release]
    panic = "abort"
    lto = true
    opt-level = "z"
    ```

7. Write your secret contract. Refer to the [example secret contracts](https://github.com/enigmampc/enigma-core/tree/develop/examples/eng_wasm_contracts): within each folder, refer to `src/lib.rs` for the actual secret contract code). A great starting point would be the `simple_calculator` that provides basic arithmetic operations (add, sub, mul, div) for any two inputs.

8. Within the `discovery-docker-network` folder, enter the `core` container by running the following command:

    ```
    docker-compose exec core /bin/bash
    ```

    which provides a Bash shell (`/bin/bash`) inside the `core` container. Once inside the container (you will see a different prompt), you need to do two things:
    
    - the first time, you need to build the `core` binaries inside the container, which varies depending on whether you are running in Hardware mode or in Simulation mode:

        _Hardware Mode_

        ```
        root@core:~# cd enigma-core/enigma-core
        root@core:~/enigma-core/enigma-core# make full-clean
        root@core:~/enigma-core/enigma-core# make DEBUG=1
        ```

        _Simulation Mode_

        ```
        root@core:~# cd enigma-core/enigma-core
        root@core:~/enigma-core/enigma-core# make full-clean
        root@core:~/enigma-core/enigma-core# SGX_MODE=SW make DEBUG=1
        ```

    - then, you can build/compile your secret contract with the following commands: 

        ```
        root@core:~/enigma-core/enigma-core# cd ~/enigma-core/examples/eng_wasm_contracts/<project_name>
        root@core:~/enigma-core/examples/eng_wasm_contracts/<project_name># cargo build --release --target wasm32-unknown-unknown
        ```

    - you can exit the container with `Ctrl` + `c`, and you will return to the prompt of your local computer.

9. The `cargo build` command above will compile your secret contract to the following path inside the container:

    ```
    ~/enigma-core/examples/eng_wasm_contracts/<project_name>/target/wasm32-unknown-unknown/release/contract.wasm
    ```

    Because this volume is mounted on your local filesystem, it will also be available at:

    ```
    /local/path/enigma-core/examples/eng_wasm_contracts/<project_name>/target/wasm32-unknown-unknown/release/contract.wasm
    ```

    It’s compiled with the name `contract.wasm` as per the package name declaration in your project `Cargo.toml` file. Copy this compiled file to the scope of your local `enigma-contract` repository in:

    ```
    /local/path/enigma-contract/enigma-js/test/integrationTests/secretContracts/
    ```

    and rename the file with a name specific to your application instead of the generic `contract.wasm` (refer to the other files in that folder for guidance).

10. Create template deploy and compute files like those already found in the [integration test folder](https://github.com/enigmampc/enigma-contract/tree/master/enigma-js/test/integrationTests) of the `enigma-contract` repository, and run the corresponding [integration tests](https://github.com/enigmampc/discovery-integration-tests/blob/develop/docs/integration.md). For example, refer to [template.02_deploy_calculator.js](https://github.com/enigmampc/enigma-contract/blob/master/enigma-js/test/integrationTests/template.02_deploy_calculator.js) and [template.10_execute_calculator.js](https://github.com/enigmampc/enigma-contract/blob/master/enigma-js/test/integrationTests/template.10_execute_calculator.js).

### Simulation mode

The docker network can run both in SGX Hardware and Software (Simulation) modes. It defaults to SGX Hardware mode. In order to run in simulation mode, you only need to:

1. Edit `.env` and change `SGX_MODE=SW`, and then re-build the `core` and `km` images:

    ```
    docker-compose build --no-cache core km
    ```

2. Launch the network with `./launch.bash` as usual.

## Troubleshooting  

See the [Troubleshooting](https://github.com/enigmampc/discovery-integration-tests/blob/develop/docs/troubleshooting.md) document for the most common errors and how to solve them.

## Advanced Topics

These resources are geared towards the advanced user who needs additional customization.


### Building the Docker images

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

where `{image_name}` is one of the following: `contract`, `p2p`, `client`, `core`, `km`, and which can be combined with the `--no-cache` option as follows:

```
$ docker-compose build --no-cache {image_name}
```

### Mounting volumes for development

By default, each of the container images are built pulling the latest version of their corresponding repositories, using the branches specified in `.env` (see Step 1 in "Running the tests" section above). There are instances in which you may want to use a local copy of that repository where you can introduce changes and test them on the network.

In order to do that you do the following:

1. Clone either one of the three repositories ([contract](https://github.com/enigmampc/enigma-contract), [core](https://github.com/enigmampc/enigma-core), [p2p](https://github.com/enigmampc/enigma-p2p)) that you are interested in, for example the contract:
	
    ```
    $ git clone https://github.com/enigmampc/enigma-contract.git
    ```

2. Edit the `docker-compose.yml` file and add a line in the `volumes` section (you may need to create that section if it's not present in the config for that container) to the container you are interested in, mapping the local folder to where you have cloned the repo to the corresponding folder inside that container (`local_folder:folder_in_container`). Again using the contract as an example, the relevant section would become:

    ```
    client:
      build:
        context: enigma-contract
        args:
          - GIT_BRANCH_CONTRACT=${GIT_BRANCH_CONTRACT}
      stdin_open: true
      tty: true
      networks:
        - net
      hostname: client
      volumes:
        - "built_contracts:/root/enigma-contract/build/contracts"
        - "/path_to/enigma-contract:/root/enigma-contract"
    ```
      
Use the following folders for each of these containers:

| Container | Repo folder inside container |
|-----------|------------------------------|
| client    | /root/enigma-contract |
| contract   | /root/enigma-contract |
| p2p        | /root/enigma-p2p |
| core       | /root/enigma-core |
| km         | /root/enigma-core |

### Running multiple workers

The number of worker nodes (a pair of `core` + `p2p` makes up one worker node) is controlled by the environment variable `NODES`, which defaults to `1` if not set. The maximum number of worker nodes is 9. For example, to launch the network with 3 nodes, run:

```
$ NODES=3 ./launch.bash
```

Advanced Tip: If you want to manually enter any `p2p` or `core` container when there is more than one, you use the `--index` parameter as follows (e.g. enter the second `p2p` container):

```
$ docker-compose exec --index=2 p2p /bin/bash
```

### Logging

By default, Docker shows the output of all containers running on the network to the stdout of the process that launched the network, color coded by container.

Additionally, the `./launch.bash` script takes an optional parameter `-l` that stores the output of each individual container in its own file inside the `logs/` folder. A subfolder is created each time the network is launched with the timestamp of the time of launch, for example: `logs/2019-05-15T00:19:36-05:00/`.

For additional details on the Docker logging capabilities pertinent to this network configuration, refer to the [Logging](https://github.com/enigmampc/discovery-integration-tests/blob/develop/docs/logging.md) documentation.

Additionally, `core` always logs to `~/.enigma/debug.log` inside the container (verbosity can be adjusted when `core` is launched [here](https://github.com/enigmampc/discovery-integration-tests/blob/fb03e5413efbf8ea7af58d2bed45d0fa567b5526/enigma-core/start_core.bash#L5) defaulting to displaying warnings and up).

### Integration Tests

See the [Integration Tests](https://github.com/enigmampc/discovery-integration-tests/blob/develop/docs/integration.md) document for additional details on how to run the existing suite of integration tests.

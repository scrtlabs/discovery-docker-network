# Enigma Discovery Docker Network

| Service | Master | Develop |
|---------|--------|---------|
| Drone (SGX_MODE=HW) | [<img src="https://drone.enigma.co/api/badges/enigmampc/discovery-integration-tests/status.svg?branch=master"/>](https://drone.enigma.co/enigmampc/discovery-integration-tests) | [<img src="https://drone.enigma.co/api/badges/enigmampc/discovery-integration-tests/status.svg?branch=develop"/>](https://drone.enigma.co/enigmampc/discovery-integration-tests) | 
| Travis (SGX_MODE=SW) | [![Build Status](https://travis-ci.com/enigmampc/discovery-integration-tests.svg?token=cNBBjbVVEGszuAJUokFT&branch=master)](https://travis-ci.com/enigmampc/discovery-integration-tests) | [![Build Status](https://travis-ci.com/enigmampc/discovery-integration-tests.svg?token=cNBBjbVVEGszuAJUokFT&branch=develop)](https://travis-ci.com/enigmampc/discovery-integration-tests) |

This repository provides a Docker network that runs the upcoming Discovery release of the Enigma protocol. It integrates the the following repositories that provide the various components that make up the network: [enigma-contract](https://github.com/enigmampc/enigma-contract), [enigma-core](https://github.com/enigmampc/enigma-core) and [enigma-p2p](https://github.com/enigmampc/enigma-p2p): 

| Repo   | Branch | Build |
|--------|--------|-------|
| [enigma-contract](https://github.com/enigmampc/enigma-contract/tree/develop) | develop | [![Build Status](https://travis-ci.org/enigmampc/enigma-contract.svg?branch=develop)](https://travis-ci.org/enigmampc/enigma-contract) |
| [enigma-p2p](https://github.com/enigmampc/enigma-p2p/tree/jsonrpc-integration) | develop |[![Build Status](https://travis-ci.org/enigmampc/enigma-p2p.svg?branch=develop)](https://travis-ci.org/enigmampc/enigma-p2p) |
| [enigma-core](https://github.com/enigmampc/enigma-core/tree/develop) | develop | <img src="https://drone.enigma.co/api/badges/enigmampc/enigma-core/status.svg?branch=develop"/> |

This repository is configured for Continuous Integration (CI) on two different testing environments: Drone, where SGX runs in hardware mode, and Travis, where SGX runs in simulation mode. The tests include a comprehensive suite of integration tests across the network that cover all [these scenarios](https://github.com/enigmampc/discovery-integration-tests/issues/2). 


## Running the tests

1. Create your `env` file from the template. No need to change any environment variables. Lines 7-10 can be disregarded as they are not currently used.

    ```
    $ cp .env-template .env
    ```

2. Launch the docker network (by default runs in SGX Hardware mode, and with only one workers, see next sections to change these settings).

    ```
    $ ./launch.bash
    ```

3. ... and then, run the integration tests:

    ```
    $ docker-compose run client ./start_test.bash
    ```

## Running individual tests

After following steps 1 and 2 above, do the following:

3. Enter the "client" container:

	```
	$ docker-compose run client /bin/bash
	```

4. Change folders, and create an empty file:

	```
	root@client:~# cd enigma-contract/enigma-js/test/integrationTests
	root@client:~/enigma-contract/enigma-js/test/integrationTests# touch testList.txt
	```

5. Generate all the test files from the corresponding templates (and run no tests because `testList.txt` exists and is empty):

	```
	root@client:~/enigma-contract/enigma-js/test/integrationTests# ~/start_test.bash
	```

6. Run individual tests as needed:

	```
	root@client:~/enigma-contract/enigma-js/test/integrationTests# yarn test:integration 01_init.spec.js 
	root@client:~/enigma-contract/enigma-js/test/integrationTests# yarn test:integration 02_deploy_calculator.spec.js
	root@client:~/enigma-contract/enigma-js/test/integrationTests# yarn test:integration 10_execute_calculator.spec.js
	```
    
## Simulation mode

The docker network can run both in SGX Hardware and Software (Simulation) modes. It defaults to SGX Hardware mode. In order to run in simulation mode, you need to do two things:

1. Edit `.env` and change `SGX_MODE=SW`, and then build the docker images (Step #2 above).
2. Launch the network with `./launch.bash -s`

## Running multiple workers

The number of worker nodes (a pair of `core` + `p2p` makes up one worker node) is controlled by the environment variable `NODES`, which defaults to `1` if not set. The maximum number of worker nodes is 9. For example, to launch the network with 3 nodes, run:

```
$ NODES=3 ./launch.bash
```

Advanced Tip: If you want to manually enter any `p2p` or `core` container when there is more than one, you use the `--index` parameter as follows (e.g. enter the second `p2p` container):

```
$ docker-compose exec --index=2 p2p /bin/bash
```

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
where `{image_name}` is one of the following: `contract`, `p2p`, `client`, `core`, `km`, and which can be combined with the `--no-cache` option as follows:
```
$ docker-compose build --no-cache {image_name}
```

## Logging

By default, Docker shows the output of all containers running on the network to the stdout of the process that launched the network, color coded by container.

Additionally, the `./launch.bash` script takes an optional parameter `-l` that stores the output of each individual container in its own file inside the `logs/` folder. A subfolder is created each time the network is launched with the timestamp of the time of launch, for example: `logs/2019-05-15T00:19:36-05:00/`.

For additional details on the Docker logging capabilities pertinent to this network configuration, refer to the [Logging](https://github.com/enigmampc/discovery-integration-tests/blob/develop/docs/logging.md) documentation.

Additionally, `core` always logs to `~/.enigma/debug.log` inside the container (verbosity can be adjusted when `core` is launched [here](https://github.com/enigmampc/discovery-integration-tests/blob/fb03e5413efbf8ea7af58d2bed45d0fa567b5526/enigma-core/start_core.bash#L5) defaulting to displaying warnings and up).



## Mounting volumes for development

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
      
## Troubleshooting	

See the [Troubleshooting](https://github.com/enigmampc/discovery-integration-tests/blob/master/docs/troubleshooting.md) document for the most common errors and how to solve them.

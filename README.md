# Discovery Integration Tests

| Service | Master | Develop |
|---------|--------|---------|
| Drone (SGX_MODE=HW) | [<img src="https://drone.enigma.co/api/badges/enigmampc/discovery-integration-tests/status.svg?branch=master"/>](https://drone.enigma.co/enigmampc/discovery-integration-tests) | [<img src="https://drone.enigma.co/api/badges/enigmampc/discovery-integration-tests/status.svg?branch=develop"/>](https://drone.enigma.co/enigmampc/discovery-integration-tests) | 
| Travis (SGX_MODE=SW) | [![Build Status](https://travis-ci.com/enigmampc/discovery-integration-tests.svg?token=cNBBjbVVEGszuAJUokFT&branch=master)](https://travis-ci.com/enigmampc/discovery-integration-tests) | [![Build Status](https://travis-ci.com/enigmampc/discovery-integration-tests.svg?token=cNBBjbVVEGszuAJUokFT&branch=develop)](https://travis-ci.com/enigmampc/discovery-integration-tests) |

This repository includes a suite of Integration Tests across multiple repositories for the Discovery release of the Enigma Network.
Currently integrates with the following repositories, and their corresponding branches (eventually becoming master):

| Repo   | Branch | Build |
|--------|--------|-------|
| [enigma-contract](https://github.com/enigmampc/enigma-contract/tree/develop) | develop | [![Build Status](https://travis-ci.org/enigmampc/enigma-contract.svg?branch=develop)](https://travis-ci.org/enigmampc/enigma-contract) |
| [enigma-p2p](https://github.com/enigmampc/enigma-p2p/tree/jsonrpc-integration) | jsonrpc-integration|[![Build Status](https://travis-ci.org/enigmampc/enigma-p2p.svg?branch=jsonrpc-integration)](https://travis-ci.org/enigmampc/enigma-p2p) |
| [enigma-core](https://github.com/enigmampc/enigma-core/tree/develop) | develop | <img src="https://drone.enigma.co/api/badges/enigmampc/enigma-core/status.svg?branch=develop"/> |


Refer to [Issue #2](https://github.com/enigmampc/discovery-integration-tests/issues/2) for the status of the integration tests.


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
	root@client:~/enigma-contract/enigma-js/test/integrationTests# yarn test:integration 02_deploy_addition.spec.js
	root@client:~/enigma-contract/enigma-js/test/integrationTests# yarn test:integration 10_execute_addition.spec.js
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
| client   | /root/enigma-contract |
| contract   | /root/enigma-contract |
| p2p-proxy  | /root/enigma-p2p |
| p2p-worker | /root/enigma-p2p |
| core       | /root/enigma-core |
| principal  | /root/enigma-core |
      

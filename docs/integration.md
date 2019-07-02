# Integration Tests

You can run all and any of the integration tests documented [here](https://github.com/enigmampc/discovery-docker-network/issues/2).

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
    $ docker-compose exec client ./start_test.bash
    ```

## Running individual tests

After following steps 1 and 2 above, do the following:

3. Enter the "client" container:

	```
	$ docker-compose exec client /bin/bash
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
## Integration Tests and Continuous Integration (CI)

The integration tests have been added as additional steps to the unit tests of the contract ([PR 115](https://github.com/enigmampc/enigma-contract/pull/115)), core ([PR 176](https://github.com/enigmampc/enigma-core/pull/176)) and p2p ([PR 205](https://github.com/enigmampc/enigma-p2p/pull/205)).

To streamline running the integration tests in both CIs (Travis (contract, p2p) and Drone (core)), we maintain prebuilt Docker images of each repo ([enigmampc Docker link](https://cloud.docker.com/u/enigmampc/repository/list)) with two different tags:
- `latest`: built from branch `master` on each repo, and the images that [enigmampc/discovery-cli](https://github.com/enigmampc/discovery-cli) uses
- `develop`: built from branch `develop` on each repo, used primarily for development and testing

Due to the interdependencies between repositories, special care must be taken when pushing breaking changes across more than one repository because that will break the CI. In those special cases, some manual intervention must be done to preserve the integrity of the tests:

1. Run the integration tests locally to ensure that they pass.
2. Manually build the Docker image for repo A, and push it to the Docker Hub
3. Merge PR for repo B, and wait for the Docker image(s) to be automatically build and pushed to the Docker Hub
4. Merge PR for repo A, and wait for the Docker image(s) to be automatically build and pushed to the Docker Hub

Use the following commands for step 2 above:

- If merging onto `develop`, depending on the repo (change `GIT_BRANCH_REPO` to feature branch if needed):
```
cd discovery-docker-network/enigma-core

docker build --build-arg GIT_BRANCH_CORE=develop --build-arg SGX_MODE=HW -t enigmampc/enigma_core_hw:develop --no-cache .
docker push enigmampc/enigma_core_hw:develop

docker build --build-arg GIT_BRANCH_CORE=develop --build-arg SGX_MODE=SW -t enigmampc/enigma_core_sw:develop --no-cache .
docker push enigmampc/enigma_core_sw:develop

docker build --build-arg GIT_BRANCH_CORE=develop --build-arg SGX_MODE=HW -t enigmampc/enigma_km_hw:develop --no-cache .
docker push enigmampc/enigma_km_hw:develop

docker build --build-arg GIT_BRANCH_CORE=develop --build-arg SGX_MODE=SW -t enigmampc/enigma_km_sw:develop --no-cache .
docker push enigmampc/enigma_km_sw:develop


cd discovery-docker-network/enigma-contract

docker build --build-arg GIT_BRANCH_CONTRACT=develop -t enigmampc/enigma_contract:develop --no-cache .
docker push enigmampc/enigma_contract:develop


cd discovery-docker-network/enigma-p2p

docker build --build-arg GIT_BRANCH_P2P=develop -t enigmampc/enigma_p2p:develop --no-cache .
docker push enigmampc/enigma_p2p:develop
```

- If merging onto `master`, depending on the repo (change `GIT_BRANCH_REPO` to `develop` or `master` as needed):

> **Be extra careful when manually pushing docker images tagged `latest`**<br/>
> **because many developers depend on them!**

```
cd discovery-docker-network/enigma-core

docker build --build-arg GIT_BRANCH_CORE=develop --build-arg SGX_MODE=HW -t enigmampc/enigma_core_hw:latest --no-cache .
docker push enigmampc/enigma_core_hw:latest

docker build --build-arg GIT_BRANCH_CORE=develop --build-arg SGX_MODE=SW -t enigmampc/enigma_core_sw:latest --no-cache .
docker push enigmampc/enigma_core_sw:latest

docker build --build-arg GIT_BRANCH_CORE=develop --build-arg SGX_MODE=HW -t enigmampc/enigma_km_hw:latest --no-cache .
docker push enigmampc/enigma_km_hw:latest

docker build --build-arg GIT_BRANCH_CORE=develop --build-arg SGX_MODE=SW -t enigmampc/enigma_km_sw:latest --no-cache .
docker push enigmampc/enigma_km_sw:latest


cd discovery-docker-network/enigma-contract

docker build --build-arg GIT_BRANCH_CONTRACT=develop -t enigmampc/enigma_contract:latest --no-cache .
docker push enigmampc/enigma_contract:latest


cd discovery-docker-network/enigma-p2p

docker build --build-arg GIT_BRANCH_P2P=develop -t enigmampc/enigma_p2p:latest --no-cache .
docker push enigmampc/enigma_p2p:latest
```








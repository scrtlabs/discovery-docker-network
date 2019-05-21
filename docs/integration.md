# Integration Tests

You can run all and any of the integration tests documented [here](https://github.com/enigmampc/discovery-docker-network/issues/2)].

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
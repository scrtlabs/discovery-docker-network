This document compiles a number of errors that appear in the network and how to solve them.

* When mounting a volume for the `p2p`, you have to delete the local `node_modules` folder and run `npm install` inside the container. Otherwise some of the node libraries/dependencies are compiled against the host shared libraries that are not available inside the container or have a mismatched version. When that occurs you will see an error like the following:

```
p2p_1        | internal/modules/cjs/loader.js:846
p2p_1        |   return process.dlopen(module, path.toNamespacedPath(filename));
p2p_1        |                  ^
p2p_1        | 
p2p_1        | Error: The module '/root/enigma-p2p/node_modules/scrypt/build/Release/scrypt.node'
p2p_1        | was compiled against a different Node.js version using
p2p_1        | NODE_MODULE_VERSION 64. This version of Node.js requires
p2p_1        | NODE_MODULE_VERSION 67. Please try re-compiling or re-installing
p2p_1        | the module (for instance, using `npm rebuild` or `npm install`).
p2p_1        |     at Object.Module._extensions..node (internal/modules/cjs/loader.js:846:18)
p2p_1        |     at Module.load (internal/modules/cjs/loader.js:672:32)
p2p_1        |     at tryModuleLoad (internal/modules/cjs/loader.js:612:12)
p2p_1        |     at Function.Module._load (internal/modules/cjs/loader.js:604:3)
p2p_1        |     at Module.require (internal/modules/cjs/loader.js:711:19)
p2p_1        |     at require (internal/modules/cjs/helpers.js:14:16)
p2p_1        |     at Object.<anonymous> (/root/enigma-p2p/node_modules/scrypt/index.js:3:20)
p2p_1        |     at Module._compile (internal/modules/cjs/loader.js:805:30)
p2p_1        |     at Object.Module._extensions..js (internal/modules/cjs/loader.js:816:10)
p2p_1        |     at Module.load (internal/modules/cjs/loader.js:672:32)
```

* One of the initial tests in `01_init.spec.js` fails for no apparent reason, with a nondescriptive error such as a timeout, like the one included below:
```
 ● Init tests › should distribute ENG tokens

    Timeout - Async callback was not invoked within the 5000ms timeout specified by jest.setTimeout.

      57 |   });
      58 | 
    > 59 |   it('should distribute ENG tokens', async () => {
         |   ^
      60 |     const tokenContract = enigma.tokenContract;
      61 |     let promises = [];
      62 |     const allowance = utils.toGrains(1000);

      at Spec (node_modules/jest-jasmine2/build/jasmine/Spec.js:85:20)
      at Suite.it (test/integrationTests/01_init.spec.js:59:3)
      at Object.describe (test/integrationTests/01_init.spec.js:22:1)
```
This is usually caused by the compiled contracts being out of sync between the containers. These three containers: `contract`, `client` and `p2p` share a volume on the docker network named `built_contracts` that persists between network runs. The solution is to enter one of these containers and wipe out the contents of that shared folder and restart the network again, for example:
```
$ docker-compose exec client /bin/bash
root@client:~# cd enigma-contract/build/contracts/
root@client:~/enigma-contract/build/contracts# rm -rf *
```

* When mounting the volume for either `core` or the `km` node, you may see an error like the following in the network output:
```
core_1       | ./start_core.bash: line 6: ./target/debug/enigma-core-app: No such file or directory
```
This means that you need to enter the container in question (either `core` or `km`) and trigger a build as follows, and then restart the network again:
- `core`:
 ```
 $ docker-compose exec core /bin/bash
 root@core:~# cd enigma-core/enigma-core
 root@core:~/enigma-core/enigma-core# make full-clean && make DEBUG=1
 ```
- `key management` node:
 ```
 $ docker-compose exec km /bin/bash
 root@km:~# cd enigma-core/enigma-principal
 root@km:~/enigma-core/enigma-principal# make full-clean && make DEBUG=1
 ```

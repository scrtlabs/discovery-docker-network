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

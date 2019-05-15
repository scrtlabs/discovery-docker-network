This document compiles a number of errors that appear in the network and how to solve them.

### The module was compiled against a different Node.js

When mounting a volume for the `p2p`, you have to delete the local `node_modules` folder and run `npm install` inside the container. Otherwise some of the node libraries/dependencies are compiled against the host shared libraries that are not available inside the container or have a mismatched version. When that occurs you will see an error like the following:

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

### jest.setTimeout in 01_init.spec.js

One of the initial tests in `01_init.spec.js` fails for no apparent reason, with a nondescriptive error such as a timeout, like the one included below:
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

### ./target/debug/enigma-core-app: No such file or directory

When mounting the volume for either `core` or the `key management (km)` node, you may see an error like the following in the network output:
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

### SGX_ERROR_NO_DEVICE

You will see this error when all of the following occur:
- You are mounting a volume for `core`
- AND you are running in simulation mode (`SGX_MODE=SW`)
- AND you enter the container to build the binaries in HW mode (instead of simulation mode)

```
core_1       | 16:05:33 [INFO] LOG DERIVE: Err(SGX_ERROR_NO_DEVICE)
core_1       | thread 'main' panicked at '[-] Init Enclave Failed: SGX_ERROR_NO_DEVICE', libcore/result.rs:1009:5
core_1       | stack backtrace:
core_1       |    0: std::sys::unix::backtrace::tracing::imp::unwind_backtrace
core_1       |              at libstd/sys/unix/backtrace/tracing/gcc_s.rs:49
core_1       |    1: std::sys_common::backtrace::print
core_1       |              at libstd/sys_common/backtrace.rs:71
core_1       |              at libstd/sys_common/backtrace.rs:59
core_1       |    2: std::panicking::default_hook::{{closure}}
core_1       |              at libstd/panicking.rs:211
core_1       |    3: std::panicking::default_hook
core_1       |              at libstd/panicking.rs:227
core_1       |    4: std::panicking::rust_panic_with_hook
core_1       |              at libstd/panicking.rs:476
core_1       |    5: std::panicking::continue_panic_fmt
core_1       |              at libstd/panicking.rs:390
core_1       |    6: rust_begin_unwind
core_1       |              at libstd/panicking.rs:325
core_1       |    7: core::panicking::panic_fmt
core_1       |              at libcore/panicking.rs:77
core_1       |    8: core::result::unwrap_failed
core_1       |              at libcore/macros.rs:26
core_1       |    9: <core::result::Result<T, E>>::expect
core_1       |              at libcore/result.rs:835
core_1       |   10: enigma_core_app::main
core_1       |              at src/main.rs:27
core_1       |   11: std::rt::lang_start::{{closure}}
core_1       |              at libstd/rt.rs:74
core_1       |   12: std::panicking::try::do_call
core_1       |              at libstd/rt.rs:59
core_1       |              at libstd/panicking.rs:310
core_1       |   13: __rust_maybe_catch_panic
core_1       |              at libpanic_unwind/lib.rs:102
core_1       |   14: std::rt::lang_start_internal
core_1       |              at libstd/panicking.rs:289
core_1       |              at libstd/panic.rs:392
core_1       |              at libstd/rt.rs:58
core_1       |   15: std::rt::lang_start
core_1       |              at libstd/rt.rs:74
core_1       |   16: main
core_1       |   17: __libc_start_main
core_1       |   18: _start
```
The error is self-explanatory: the `core` binaries were compiled in Hardware mode, but no SGX device is available in the system (no `/dev/isgx` because it is running in simulation mode). The fix is straightforward, with the network up, execute:
```
$ docker-compose exec core /bin/bash
root@core:~# cd enigma-core/enigma-core
root@core:~/enigma-core/enigma-core# SGX_MODE=SW make DEBUG=1
```

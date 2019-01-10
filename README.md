# discovery-integration-tests

[![Build Status](https://travis-ci.com/enigmampc/discovery-integration-tests.svg?token=cNBBjbVVEGszuAJUokFT&branch=develop)](https://travis-ci.com/enigmampc/discovery-integration-tests)

This repository includes a suite of Integration Tests across multiple repositories for the Discovery release of the Enigma Network.
Currently integrates with the following repositories, and their corresponding branches (eventually becoming master):

| Repo   | Branch | Build |
|--------|--------|-------|
| [enigma-contract-internal](https://github.com/enigmampc/enigma-contract-internal/tree/integration-tests) | integration-tests | [![Build Status](https://travis-ci.com/enigmampc/enigma-contract-internal.svg?token=cNBBjbVVEGszuAJUokFT&branch=integration-tests)](https://travis-ci.com/enigmampc/enigma-contract-internal) |
| [enigma-p2p](https://github.com/enigmampc/enigma-p2p/tree/jsonrpc-integration) | jsonrpc-integration|[![Build Status](https://travis-ci.com/enigmampc/enigma-p2p.svg?token=cNBBjbVVEGszuAJUokFT&branch=jsonrpc-integration)](https://travis-ci.com/enigmampc/enigma-p2p) |
| [enigma-core-internal](https://github.com/enigmampc/enigma-core-internal/tree/main) | main | <img src="https://drone.enigma.co/api/badges/enigmampc/enigma-core-internal/status.svg?branch=main"/> |

The following is a list of the Integration Tests planned, and their status:

| Status | Test |
|--------|------|
| Pass   | Client requests encryption key from worker |
|        | Register a new worker node in the Enigma contract |
|        | Deploy a new contract |
|        | Compute Task |

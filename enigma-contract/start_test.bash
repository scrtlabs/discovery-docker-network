#!/bin/bash

./init.bash
cd enigma-contract/enigma-js && test/integrationTests/runTests.bash

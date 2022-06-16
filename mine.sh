#!/usr/bin/bash

curl --data '{"jsonrpc":"2.0","method":"anvil_mine", "params":['"$1"'],"id":1}' -H "Content-Type: application/json" localhost:8545

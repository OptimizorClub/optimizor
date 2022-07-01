#!/usr/bin/bash

source "./.env_anvil"

# env contains
# RPC_URL
# PRIVATE_KEY
# ETH_FROM
# all from Anvil

forge script script/Optimizor.s.sol:OptimizorScript --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY --broadcast --slow

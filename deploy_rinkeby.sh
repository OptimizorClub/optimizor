#!/usr/bin/bash

source "./.env"

# env should contain
# RPC_URL
# ETH_FROM
# ETH_KEYSTORE pointing to the JSON and not to the directory
# ETH_PASSWD

forge script script/Optimizor.s.sol:OptimizorScript --rpc-url=$RPC_URL --broadcast --sender=$ETH_FROM --slow --password=$ETH_PASSWD --keystores=$ETH_KEYSTORE

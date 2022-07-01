#!/usr/bin/bash

source "./.env_anvil"

# env contains
# RPC_URL
# PRIVATE_KEY
# ETH_FROM
# all from Anvil

# Collect the addresses below from `deploy_anvil.sh`

nft="0x5fbdb2315678afecb367f032d93f642f64180aa3";
sumChl="0xe7f1725e7734ce288f8367e1bb143e90bb3f0512";
expSum="0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0";
cheapSum="0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9";

expSumCodehash="0x78db5f193e0653ae2c575a04fa3049e290f71a11e30eb1067385e5d4de33c1b5";

cast send --rpc-url=$RPC_URL $nft "addChallenge(uint256,address)" "0" $sumChl --private-key=$PRIVATE_KEY

cast send --rpc-url=$RPC_URL $nft "commit(bytes32)" $expSumCodehash --private-key=$PRIVATE_KEY

# This is needed to test in non-TESTNET mode
#./mine.sh 520

cast send --rpc-url=$RPC_URL $nft "challenge(uint256,bytes32,address,address)" "0" $expSumCodehash $expSum $ETH_FROM --gas 3000000 --private-key=$PRIVATE_KEY

cast call --rpc-url=$RPC_URL $nft "tokenURI(uint256)" "1"

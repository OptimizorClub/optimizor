#!/usr/bin/bash

source "./.env"

# env should contain
# RPC_URL
# ETH_FROM
# ETH_KEYSTORE pointing to the JSON and not to the directory
# ETH_PASSWD

# Collect the addresses below from `deploy_rinkeby.sh`

nft="0x94115519cb0aff3dc690d58433c0ae65110a6ef8";
sumChl="0x00485951ae7179a288fb652efb1ee22e5150c447";
expSum="0xd0b1a4250a7557af9bf908d1d07bef5f616f3d53";
cheapSum="0x7f2bb7040b3a8d5044dd36d8be118cc3a295edb3";

expSumCodehash="0x78db5f193e0653ae2c575a04fa3049e290f71a11e30eb1067385e5d4de33c1b5";

# rinkeby
cast send --rpc-url=$RPC_URL --password=$ETH_PASSWD --keystore=$ETH_KEYSTORE $nft "addChallenge(uint256,address)" "0" $sumChl

cast send --rpc-url=$RPC_URL --password=$ETH_PASSWD --keystore=$ETH_KEYSTORE $nft "commit(bytes32)" $expSumCodehash

cast send --rpc-url=$RPC_URL --password=$ETH_PASSWD --keystore=$ETH_KEYSTORE $nft "challenge(uint256,bytes32,address,address)" "0" $expSumCodehash $expSum $expSum --gas 3000000

cast call --rpc-url=$RPC_URL $nft "tokenURI(uint256)" "1"

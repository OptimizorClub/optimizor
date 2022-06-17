#!/usr/bin/bash

source "./.env"

# env should contain
# RPC_URL
# ETH_FROM
# ETH_KEYSTORE pointing to the JSON and not to the directory
# ETH_PASSWD

# Collect the addresses below from `deploy_rinkeby.sh`

nft="0x7de559f0778f3476cd5959f24df8ccc9d0f817f4";
sumChl="0x520e56ddeb24b36e0e9b17f80a331f3faeaa87da";
expSum="0xd02c08eae82ba1997f106888d9a634aeb9900a31";
cheapSum="0x1bee1750d2240c7af2c896971628afb17daec1ff";

#nft="0x91598f4d70ea6724ab600428a3a5162a66020a06";
#sumChl="0x7d26431d03d08cc142ef954e8b1fb46fc9fedf5d";
#expSum="0x2a8404682f571d761f34b3400df717baec0e67ec";
#cheapSum="0x1c19f62b52779c252c2ba28d5cb7d7ebc9ce0330";

#nft="0xf4e58a766728a5dd3c2302ddee9af6b39f6d892e";
#sumChl="0xb8c760e008ad2792bb8473e04bcbde9104e6aa3a";
#expSum="0x65cfe987f20128c02e7b69194ead3d415b1a6c6d";
#cheapSum="0x73948acb5a69eef063a71dc92a861fd87d845fac";

#nft="0xa5a03258799a04972aea247656a230a63a4ddeb8";
#sumChl="0x1b1fd2b19cb4b56cddb4d33e3360988037abdf2b";
#expSum="0x28e2c5ac7aae7f3435ab2b6920b6efad335bd519";
#cheapSum="0x7dcc67a53d5b635dcef8bfc053e22e2be3bb9a81";

expSumCodehash="0x78db5f193e0653ae2c575a04fa3049e290f71a11e30eb1067385e5d4de33c1b5";

# rinkeby
cast send --rpc-url=$RPC_URL --password=$ETH_PASSWD --keystore=$ETH_KEYSTORE $nft "addChallenge(uint256,address)" "0" $sumChl

cast send --rpc-url=$RPC_URL --password=$ETH_PASSWD --keystore=$ETH_KEYSTORE $nft "commit(bytes32)" $expSumCodehash

cast send --rpc-url=$RPC_URL --password=$ETH_PASSWD --keystore=$ETH_KEYSTORE $nft "challenge(uint256,bytes32,address,address)" "0" $expSumCodehash $expSum $expSum --gas 3000000

cast call --rpc-url=$RPC_URL $nft "tokenURI(uint256)" "1"

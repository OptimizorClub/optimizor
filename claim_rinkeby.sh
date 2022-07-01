#!/usr/bin/bash

source "./.env"

# env should contain
# RPC_URL
# ETH_FROM
# ETH_KEYSTORE pointing to the JSON and not to the directory
# ETH_PASSWD

# Collect the addresses below from `deploy_rinkeby.sh`

nft="0xf01a503daccaf9ff651350e63f420d5b0e9bbf70";
sumChl="0xfe4df1b628c1d2c385dc0b6604da8fefadeef240";
expSum="0x2968ef22533d8b7356ebd8243a4ce903fbe03c4c";
cheapSum="0xfc09c71de4813efc06cc0cd2bcbf1b379bea5a1b";

#nft="0x7de559f0778f3476cd5959f24df8ccc9d0f817f4";
#sumChl="0x520e56ddeb24b36e0e9b17f80a331f3faeaa87da";
#expSum="0xd02c08eae82ba1997f106888d9a634aeb9900a31";
#cheapSum="0x1bee1750d2240c7af2c896971628afb17daec1ff";

expSumCodehash="0x78db5f193e0653ae2c575a04fa3049e290f71a11e30eb1067385e5d4de33c1b5";

# rinkeby
cast send --rpc-url=$RPC_URL --password=$ETH_PASSWD --keystore=$ETH_KEYSTORE $nft "addChallenge(uint256,address)" "0" $sumChl

cast send --rpc-url=$RPC_URL --password=$ETH_PASSWD --keystore=$ETH_KEYSTORE $nft "commit(bytes32)" $expSumCodehash

cast send --rpc-url=$RPC_URL --password=$ETH_PASSWD --keystore=$ETH_KEYSTORE $nft "challenge(uint256,bytes32,address,address)" "0" $expSumCodehash $expSum $expSum --gas 3000000

cast call --rpc-url=$RPC_URL $nft "tokenURI(uint256)" "1"

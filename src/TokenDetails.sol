// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Challenge.sol";

struct TokenDetails {
    uint challengeId;
    IChallenge challenge;

    uint32 leaderGas;
    uint32 leaderLevel;
    address leaderRecordHolder;
    address leaderOwner;
    address leaderChallenger;

    uint32 gas;
    uint32 level;
    address recordHolder;
    address owner;
    address challenger;
}


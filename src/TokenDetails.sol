// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IChallenge.sol";

struct TokenDetails {
    uint challengeId;
    IChallenge challenge;

    uint32 leaderGas;
    uint32 leaderLevel;
    address leaderSolver;
    address leaderOwner;
    address leaderChallenger;

    uint32 gas;
    uint32 level;
    address solver;
    address owner;
    address challenger;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IChallenge} from "./IChallenge.sol";

struct TokenDetails {
    uint challengeId;
    IChallenge challenge;

    uint32 leaderGas;
    uint32 leaderLevel;
    address leaderSolver;
    address leaderOwner;
    address leaderSubmission;

    uint32 gas;
    uint32 level;
    uint32 rank;
    uint32 improvementPercentage;
    address solver;
    address owner;
    address submission;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import {IChallenge} from "src/IChallenge.sol";

struct TokenDetails {
    uint256 challengeId;
    IChallenge challenge;
    uint32 leaderGas;
    uint32 leaderSolutionId;
    address leaderSolver;
    address leaderOwner;
    address leaderSubmission;
    uint32 gas;
    uint32 solutionId;
    uint32 rank;
    uint32 improvementPercentage;
    address solver;
    address owner;
    address submission;
}

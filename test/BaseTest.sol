// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.15;

import {SUM_ID, SQRT_ID} from "./ChallengeIDs.sol";
import {ISum, SumChallenge, CheapSum, ExpensiveSum} from "./SumChallenge.sol";
import {ISqrt, SqrtChallenge, CheapSqrt, ExpensiveSqrt} from "./SqrtChallengeSolutions.sol";

import {Optimizor, EPOCH} from "../src/Optimizor.sol";
import {IChallenge} from "../src/IChallenge.sol";
import {IPurityChecker} from "../src/IPurityChecker.sol";
import {PurityChecker} from "../src/PurityChecker.sol";

import "forge-std/Test.sol";

contract BaseTest is Test {
    IPurityChecker purity;
    Optimizor opt;
    IChallenge sum;
    IChallenge sqrt;

    ISum cheapSum;
    ISum expSum;

    ISqrt cheapSqrt;
    ISqrt expSqrt;

    function setUp() public {
        purity = new PurityChecker();
        opt = new Optimizor(purity);
        sum = new SumChallenge();
        sqrt = new SqrtChallenge();

        cheapSum = new CheapSum();
        expSum = new ExpensiveSum();

        cheapSqrt = new CheapSqrt();
        expSqrt = new ExpensiveSqrt();
    }

    function addSumChallenge() internal {
        opt.addChallenge(SUM_ID, sum);
    }

    function addSqrtChallenge() internal {
        opt.addChallenge(SQRT_ID, sqrt);
    }

    function advancePeriod() internal {
        vm.roll(block.number + EPOCH + 1);
    }
}

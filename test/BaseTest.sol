// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.15;

import "./ChallengeIDs.sol";
import "./SumChallenge.sol";
import "./SqrtChallengeSolutions.sol";
import "../src/PurityChecker.sol";

import "../src/Optimizor.sol";

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

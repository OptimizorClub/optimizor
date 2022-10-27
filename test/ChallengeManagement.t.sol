// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {BaseTest} from "test/BaseTest.sol";
import {NON_USED_ID} from "test/ChallengeIDs.sol";
import {computeKey} from "test/CommitHash.sol";

import {OptimizorAdmin} from "src/OptimizorAdmin.sol";
import {OptimizorNFT} from "src/OptimizorNFT.sol";

import "forge-std/Test.sol";

contract ChallengeManagementTest is BaseTest {
    function testAddSumChallenge() public {
        addSumChallenge();
    }

    function testDupAddSumChallenge() public {
        addSumChallenge();

        vm.expectRevert(abi.encodeWithSelector(OptimizorAdmin.ChallengeExists.selector, uint256(0)));
        addSumChallenge();
    }

    function testAddChallengeNonAdmin() public {
        address other = address(42);
        vm.prank(other);

        vm.expectRevert("UNAUTHORIZED");
        addSumChallenge();
    }

    function testAddExistingChallengeNonAdmin() public {
        addSumChallenge();

        address other = address(42);
        vm.prank(other);

        vm.expectRevert("UNAUTHORIZED");
        addSumChallenge();
    }

    function testNonExistentChallenge() public {
        opt.commit(computeKey(address(this), 0, 0));

        advancePeriod();
        advancePeriod();

        vm.expectRevert(abi.encodeWithSelector(OptimizorNFT.ChallengeNotFound.selector, type(uint256).max));
        opt.challenge(NON_USED_ID, address(0), address(0), 0);
    }
}

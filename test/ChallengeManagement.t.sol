// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.15;

import "./BaseTest.sol";
import "./CommitHash.sol";

import "../src/OptimizorNFT.sol";

import "forge-std/Test.sol";

contract ChallengeManagementTest is BaseTest {
    function testAddSumChallenge() public {
        addSumChallenge();
    }

    function testDupAddSumChallenge() public {
        addSumChallenge();

        vm.expectRevert(abi.encodeWithSignature("ChallengeExists(uint256)", uint(0)));
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

        vm.expectRevert(abi.encodeWithSignature("ChallengeNotFound(uint256)", type(uint).max));
        opt.challenge(NON_USED_ID, address(0), address(0), 0);
    }
}

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.14;

import "./BaseTest.sol";
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
		// TODO
	}

	function testAddExistingChallengeNonAdmin() public {
		// TODO
	}

	function testNonExistentChallenge() public {
		advancePeriod();
		advancePeriod();
		//vm.roll(block.number + 512);
		vm.expectRevert(abi.encodeWithSignature("ChallengeNotFound(uint256)", type(uint).max));
		opt.challenge(NON_USED_ID, bytes32(0), address(0), address(0));
    }

}

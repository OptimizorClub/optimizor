// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Challenge.sol";
import "./Time.sol";

error ChallengeNotFound(uint);
error ChallengeFailed(uint);
error ChallengeExists(uint);
error NotOptimizor(uint, uint, uint);
error AddressCodeMismatch();

contract Optimizor is Time {
	// TODO add events

	struct State {
		IChallenge target;
		uint gasUsed;
		address holder;
	}

	// TODO challenge address to State/id map?

	// slot 0
	mapping (uint => State) public challenges;

	// slot 1
	address immutable admin;
	uint8 lock;
	uint128 salt;

	modifier onlyAdmin {
		require(msg.sender == admin);
		_;
	}

	modifier noReentrancy {
		require(lock == 1);
		lock = 2;
		_;
		lock = 1;
	}

	constructor() {
		admin = msg.sender;
		lock = 1;
	}

	function addChallenge(uint id, IChallenge challenge) external onlyAdmin {
		State storage chl = challenges[id];
		if (address(chl.target) != address(0)) {
			revert ChallengeExists(id);
		}

		chl.target = challenge;
	}

	/// The challenge period is the 256 blocks
	function challenge(uint256 id, bytes32 codehash, address target, address recipient) inChallengePeriod external returns (bool) {
		State storage chl = challenges[id];

		if (address(chl.challenge) == address(0)) {
			revert ChallengeNotFound(id);
		}

		if (codehashes[codehash] == address(0)) {
			revert CodeNotSubmitted();
		}

		if (target.codehash != codehash) {
			revert AddressCodeMismatch();
		}

		bytes32 seed = blockhash(revealBlock());

		if (seed == 0) {
			revert BlockHashNotFound();
		}

		if (chl.target == IChallenge(address(0))) {
			revert ChallengeNotFound(id);
		}

		(bool success, uint gas) = challenges[id].run(target, seed);

		if (!success) {
			revert ChallengeFailed(id);
		}

		if (chl.gasUsed != 0 && (chl.gasUsed <= gas)) {
			revert NotOptimizor(id, chl.gasUsed, gas);
		}

		chl.gasUsed = gas;
		chl.holder = recipient;
		// TODO mint nft
		// TODO record leaderboard

		return true;
	}
}

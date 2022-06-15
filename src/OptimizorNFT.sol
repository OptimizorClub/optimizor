// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Challenge.sol";
import "./Time.sol";

error ChallengeNotFound(uint);
error ChallengeFailed(uint);
error ChallengeExists(uint);
error NotOptimizor(uint, uint, uint);
error AddressCodeMismatch();
error BlockHashNotFound();
error CodeNotSubmitted();

contract Optimizor is Time {
	// TODO add events

	struct Data {
		// slot 0
		uint gasUsed;
		// slot 1
		IChallenge target;
		// slot 2
		address holder;
		uint32 level;
	}

	// slot 0
	mapping (uint => Data) public challenges;

	// slot 1
	address immutable admin;
	uint8 lock;

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

	function addChallenge(uint id, IChallenge chlAddr) external onlyAdmin {
		Data storage chl = challenges[id];
		if (address(chl.target) != address(0)) {
			revert ChallengeExists(id);
		}

		chl.target = chlAddr;
	}

	function challenge(
		uint256 id,
		bytes32 codehash,
		address target,
		address recipient
	) inChallengePeriod external returns (bool) {
		Data storage chl = challenges[id];

		if (address(chl.target) == address(0)) {
			revert ChallengeNotFound(id);
		}

		if (codehashes[codehash] == address(0)) {
			revert CodeNotSubmitted();
		}

		if (target.codehash != codehash) {
			revert AddressCodeMismatch();
		}

		uint boundaryBlock = ((block.number - startBlock) / 768) * 768 + 511;
		bytes32 seed = blockhash(boundaryBlock);
		if (seed == 0) {
			revert BlockHashNotFound();
		}

		if (chl.target == IChallenge(address(0))) {
			revert ChallengeNotFound(id);
		}

		(bool success, uint gas) = chl.target.run(target, uint(seed));

		if (!success) {
			revert ChallengeFailed(id);
		}

		if (chl.gasUsed != 0 && (chl.gasUsed <= gas)) {
			revert NotOptimizor(id, chl.gasUsed, gas);
		}

		chl.gasUsed = gas;
		chl.holder = recipient;
		++chl.level;

		uint tokenId = (id << 32) | level;
		ERC721._mint(recipient, tokenId);

		// TODO record leaderboard

		return true;
	}
}

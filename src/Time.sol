// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Time {
	/// Currently in the challenge period.
	error InChallengePeriod(uint period, uint startBlock, uint blockNumber);
	/// Currently not in the challenge period.
	error NotInChallengePeriod(uint period, uint startBlock, uint blockNumber);
	error CodeAlreadySubmitted();
	error CodeNotSubmitted();

	uint256 immutable public startBlock;

	mapping (bytes32 => address) public codehashes;

	constructor() {
		startBlock = block.number;
	}

	// 3 periods:
	// [0, 256) commit
	// [256, 512) wait
	// [512, 768) challenge
	function period() view public returns (uint256) {
		unchecked {
			return ((block.number - startBlock) % 768) / 256;
		}
	}

	modifier inCommitPeriod {
		if (period() != 0) {
			revert InChallengePeriod(period(), startBlock, block.number);
		}
		_;
	}

	modifier inChallengePeriod {
		if (period() != 2) {
			revert NotInChallengePeriod(period(), startBlock, block.number);
		}
		_;
	}

	function commit(bytes32 codehash) inCommitPeriod external {
		if (codehashes[codehash] != address(0)) {
			revert CodeAlreadySubmitted();
		}
		codehashes[codehash] = msg.sender;
	}
}

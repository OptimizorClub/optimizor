// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Challenge.sol";
import "./Time.sol";
import "./base64.sol";

import "solmate/auth/Owned.sol";
import "solmate/tokens/ERC721.sol";
import "solmate/utils/ReentrancyGuard.sol";



contract Optimizor is Owned, ReentrancyGuard, Time, ERC721 {
	error ChallengeNotFound(uint challengeId);
	error ChallengeExists(uint challengeId);
	error NotOptimizor();
	error AddressCodeMismatch();
	error BlockHashNotFound();
	error CodeNotSubmitted();

	event ChallengeAdded(uint challengeId, IChallenge);

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

	constructor()
		ERC721("Test", "TTT")
		Owned(msg.sender) {
	}

	function addChallenge(uint id, IChallenge chlAddr) external onlyOwner {
		Data storage chl = challenges[id];
		if (address(chl.target) != address(0)) {
			revert ChallengeExists(id);
		}

		chl.target = chlAddr;

		emit ChallengeAdded(id, chlAddr);
	}

	function challenge(
		uint256 id,
		bytes32 codehash,
		address target,
		address recipient
	) inChallengePeriod nonReentrant external {
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

		bytes32 seed = blockhash(boundaryBlock());
		if (seed == 0) {
			revert BlockHashNotFound();
		}

		if (chl.target == IChallenge(address(0))) {
			revert ChallengeNotFound(id);
		}

		uint gas = chl.target.run(target, uint(seed));

		if (chl.gasUsed != 0 && (chl.gasUsed <= gas)) {
			revert NotOptimizor();
		}

		chl.gasUsed = gas;
		chl.holder = recipient;
		unchecked {
			++chl.level;
		}

		uint tokenId = (id << 32) | chl.level;
		ERC721._mint(recipient, tokenId);
	}

	function winnerLevel(uint id) public view returns (uint32) {
		require(_ownerOf[id] != address(0));

		while (_ownerOf[id] != address(0)) {
			++id;
		}

		return uint32(id);
	}

	function svg() internal pure returns (string memory) {
		return "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'>\
  <rect width='300' height='100' style='fill:rgb(0,0,255);stroke-width:3;stroke:rgb(0,0,0)' />\
</svg>";
	}

    function tokenURI(uint256 /*id*/) public pure override returns (string memory) {
		//uint32 level = uint32(id);
		//bool winner = winnerLevel(id) == level;

		string memory meta = string(
			abi.encodePacked(
				'{\n"name": "', "TestName",
				'"\n,"description": "', "TestDescriptionnnnnnnnnnnnnnnnnnnnnnnnnn",
				'"\n,"attributes":', "[]"
			)
		);

		meta = string(
			abi.encodePacked(
				meta,
				'\n,"image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg()))
			)
		);

		meta =  string(
			abi.encodePacked(
				meta,
				'"\n}'
			)
		);

		string memory json = Base64.encode(bytes(meta));
		string memory output = string(
			abi.encodePacked("data:application/json;base64,", json)
		);
		return output;
    }
}


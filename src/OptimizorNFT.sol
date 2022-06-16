// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Challenge.sol";
import "./Time.sol";

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

    function tokenURI(uint256 /*id*/) public pure override returns (string memory) {
		//uint32 level = uint32(id);
		//bool winner = winnerLevel(id) == level;

		//string memory image_data = "data:image/svg+xml;charset=UTF-8,%3Csvg xmlns='http://www.w3.org/2000/svg' height='100' width='100' style='background-color:green'%3E%3Ccircle cx='50' cy='50' r='40' stroke='black' stroke-width='3' fill='red' /%3E%3C/svg%3E";
		string memory meta = string(
			abi.encodePacked(
				'{\n"name": "', "TestName",
				'"\n,"description": "', "TestDescriptionnnnnnnnnnnnnnnnnnnnnnnnnn",
				'"\n,"attributes":', "[]"
			)
		);

		/*
		meta = string(
			abi.encodePacked(
				meta,
				'"\n,"image_data": "', image_data
			)
		);
		*/

		meta = string(
			abi.encodePacked(
				meta,
				'\n,"image": "', "https://freesvg.org/img/Placeholder.png"
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

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Challenge.sol";
import "./Time.sol";
import "./base64.sol";

import "./NFTSVG.sol";

import "solmate/auth/Owned.sol";
import "solmate/tokens/ERC721.sol";
import "solmate/utils/ReentrancyGuard.sol";
import '@openzeppelin/contracts/utils/Strings.sol';



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
		//require(_ownerOf[id] != address(0));

		while (_ownerOf[id] != address(0)) {
			++id;
		}

		return uint32(id);
	}

	function svg(uint tokenId) internal view returns (string memory) {
		uint32 level = uint32(tokenId);
		bool winner = winnerLevel(tokenId) == level;

		uint challengeId = tokenId >> 32;
		Data storage chl = challenges[challengeId];

        NFTSVG.SVGParams memory svgParams = NFTSVG.SVGParams({
            quoteToken: "optimizoor",
            baseToken: "sqrt",
            poolAddress: address(this),
            quoteTokenSymbol: "$OPTI",
            baseTokenSymbol: "$BASE",
            feeTier: "0.5",
            tickLower: 1,
            tickUpper: 2,
            tickSpacing: 1,
            overRange: 8,
            tokenId: tokenId,

			color0: tokenToColorHex(uint256(uint160(address(chl.target))), 136),
            color1: tokenToColorHex(uint256(uint160(chl.holder)), 136),
            color2: tokenToColorHex(uint256(uint160(address(chl.target))), 0),
            color3: tokenToColorHex(uint256(uint160(chl.holder)), 0),

			x1: scale(getCircleCoord(uint256(uint160(address(chl.target))), 16, tokenId), 0, 255, 16, 274),
            y1: scale(getCircleCoord(uint256(uint160(chl.holder)), 16, tokenId), 0, 255, 100, 484),
            x2: scale(getCircleCoord(uint256(uint160(address(chl.target))), 32, tokenId), 0, 255, 16, 274),
            y2: scale(getCircleCoord(uint256(uint160(chl.holder)), 32, tokenId), 0, 255, 100, 484),
            x3: scale(getCircleCoord(uint256(uint160(address(chl.target))), 48, tokenId), 0, 255, 16, 274),
            y3: scale(getCircleCoord(uint256(uint160(chl.holder)), 48, tokenId), 0, 255, 100, 484)
			/*
            color0: "red",
            color1: "blue",
            color2: "green",
            color3: "orange"
			*/
			/*
            x1: "sss",
            y1: "y11",
            x2: "x22",
            y2: "y22",
            x3: "x33",
            y3: "y33"
			*/
        });

        return NFTSVG.generateSVG(
			svgParams,
			chl.target.svg(tokenId)
		);
	}

    function tokenURI(uint256 id) public view override returns (string memory) {
		return
			string(
				abi.encodePacked(
					'data:application/json;base64,',
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name":"',
								"TestName",
								'", "description":"',
								"Descriptionnnnnnnnnnn",
								'", "image": "',
								'data:image/svg+xml;base64,',
								Base64.encode(bytes(svg(id))),
								'"}'
							)
						)
					)
				)
			);
	}

	function tokenToColorHex(uint256 token, uint256 offset) internal pure returns (string memory str) {
        return string(toHexStringNoPrefix((token >> offset), 3));
    }

	function toHexStringNoPrefix(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length);
        for (uint256 i = buffer.length; i > 0; i--) {
            buffer[i - 1] = ALPHABET[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }

	function scale(
        uint256 n,
        uint256 inMn,
        uint256 inMx,
        uint256 outMn,
        uint256 outMx
    ) private pure returns (string memory) {
        return Strings.toString(((n - inMn) * (outMx - outMn)) / (inMx - inMn) + outMn);
    }

	function getCircleCoord(
        uint256 tokenAddress,
        uint256 offset,
        uint256 tokenId
    ) internal pure returns (uint256) {
        return (sliceTokenHex(tokenAddress, offset) * tokenId) % 255;
    }

	function sliceTokenHex(uint256 token, uint256 offset) internal pure returns (uint256) {
        return uint256(uint8(token >> offset));
    }

    bytes16 constant ALPHABET = '0123456789abcdef';
}


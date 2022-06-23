// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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
        uint rank = 1;
        uint participants = 20;

        uint challengeId = tokenId >> 32;
        Data storage chl = challenges[challengeId];
        string memory name = chl.target.name();

        NFTSVG.SVGParams memory svgParams = NFTSVG.SVGParams({
            quoteToken: "Optimizor",
            baseToken: name,
            poolAddress: address(this),
            quoteTokenSymbol: NFTSVG.toHexString(uint(uint160(address(chl.holder))), 20),
            baseTokenSymbol: NFTSVG.toHexString(uint(uint160(address(chl.target))), 20),
            feeTier:
                string.concat(
                    "Rank #",
                    Strings.toString(rank),
                    "/",
                    Strings.toString(participants)
                ),
            tickLower: int24(int(chl.gasUsed)),
            tickUpper: int24(int(chl.gasUsed + 100)),
            overRange: int8(int256(uint256(keccak256(abi.encodePacked(tokenId))))) % 3,
            tokenId: tokenId,
            rank: uint32(rank),
            participants: 10,

            color0: NFTSVG.tokenToColorHex(uint256(uint160(address(chl.target))), 136),
            color1: NFTSVG.tokenToColorHex(uint256(uint160(chl.holder)), 136),
            color2: NFTSVG.tokenToColorHex(uint256(uint160(address(chl.target))), 0),
            color3: NFTSVG.tokenToColorHex(uint256(uint160(chl.holder)), 0),

            x1: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(address(chl.target))), 16, tokenId), 0, 255, 16, 274),
            y1: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(chl.holder)), 16, tokenId), 0, 255, 100, 484),
            x2: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(address(chl.target))), 32, tokenId), 0, 255, 16, 274),
            y2: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(chl.holder)), 32, tokenId), 0, 255, 100, 484),
            x3: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(address(chl.target))), 48, tokenId), 0, 255, 16, 274),
            y3: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(chl.holder)), 48, tokenId), 0, 255, 100, 484)
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
}

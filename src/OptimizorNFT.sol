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
        uint32 gasUsed;
        IChallenge target;
        // slot 1
        address holder;
        uint32 level;
    }

    mapping (uint => Data) public challenges;
    mapping (uint => uint) extraDetails;

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

        uint32 gas = uint32(chl.target.run(target, uint(seed)));

        if (chl.gasUsed != 0 && (chl.gasUsed <= gas)) {
            revert NotOptimizor();
        }

        chl.gasUsed = gas;
        chl.holder = recipient;
        unchecked {
            ++chl.level;
        }

        uint tokenId = packTokenId(id, chl.level);
        ERC721._mint(recipient, tokenId);
        extraDetails[tokenId] = packExtraDetail(recipient, chl.gasUsed);
    }

    function leaderboard(uint tokenId) public view returns (address[] memory board) {
        (uint challengeId, ) = unpackTokenId(tokenId);
        uint32 winners = challenges[challengeId].level;
        board = new address[](winners);
        for (uint32 i = 1; i <= winners; ++i) {
            (address recipient, ) = unpackExtraDetail(packTokenId(challengeId, i));
            board[i - 1] = recipient;
        }
    }

    function svg(uint tokenId) internal view returns (string memory) {
        (uint challengeId, uint32 thisLevel) = unpackTokenId(tokenId);

        uint32 wLevel = challenges[challengeId].level;
        uint32 rank = wLevel - thisLevel + 1;

        Data storage chl = challenges[challengeId];
        string memory name = chl.target.name();

        NFTSVG.SVGParams memory svgParams = NFTSVG.SVGParams({
            projectName: "Optimizor",
            challengeName: name,
            holderAddr: NFTSVG.toHexString(uint(uint160(address(chl.holder))), 20),
            challengeAddr: NFTSVG.toHexString(uint(uint160(address(chl.target))), 20),
            gasUsed: chl.gasUsed,
            gasOpti: 10,
            overRange: int8(int256(uint256(keccak256(abi.encodePacked(tokenId))))) % 3,
            tokenId: tokenId,
            rank: rank,
            participants: wLevel,

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

    function leaderboardString(uint tokenId) public view returns (bytes memory) {
        address[] memory leaders = leaderboard(tokenId);
        bytes memory leadersStr = "";
        uint lIdx = leaders.length;
        for (uint i = 0; i < leaders.length; ++i) {
            leadersStr = abi.encodePacked(
                "\\n",
                Strings.toString(lIdx),
                ". ",
                Strings.toHexString(uint(uint160(leaders[i])), 20),
                leadersStr
            );
            --lIdx;
        }
        return abi.encodePacked("Leaderboard:", leadersStr);
    }

    function attributes(uint tokenId) internal view returns (bytes memory) {
        return "";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
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
                                leaderboardString(tokenId),
                                '", "image": "',
                                'data:image/svg+xml;base64,',
                                Base64.encode(bytes(svg(tokenId))),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function packTokenId(uint challengeId, uint32 level) internal pure returns (uint) {
        return (challengeId << 32) | level;
    }

    function unpackTokenId(uint256 tokenId) internal pure returns (uint256 challengeId, uint32 level) {
        challengeId = tokenId >> 32;
        level = uint32(tokenId);
    }

    function packExtraDetail(address recipient, uint32 gasUsed) internal pure returns (uint) {
        return (uint(uint160(recipient)) << 32) | gasUsed;
    }

    function unpackExtraDetail(uint256 tokenId) internal view returns (address recipient, uint32 gasUsed) {
        uint256 tmp = extraDetails[tokenId];
        recipient = address(uint160(tmp >> 32));
        gasUsed = uint32(tmp);
    }

    struct TokenDetails {
        uint challengeId;
        IChallenge challenge;

        uint32 currentGas;
        uint32 currentLevel;
        address currentLeader;

        uint32 gas;
        uint32 level;
        address holder;
    }

    function tokenDetails(uint256 tokenId) external view returns (TokenDetails memory details) {
        (uint challengeId, uint32 level) = unpackTokenId(tokenId);
        (address recordHolder, uint32 gasUsed) = unpackExtraDetail(tokenId);
        Data storage chl = challenges[challengeId];

        details = TokenDetails(
            challengeId,
            chl.target,

            chl.gasUsed,
            chl.level,
            chl.holder,

            gasUsed,
            level,
            recordHolder
        );
    }
}

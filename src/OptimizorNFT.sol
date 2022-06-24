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
        // TODO uncomment the line below
        require(_ownerOf[id] != address(0));

        while (_ownerOf[id] != address(0)) {
            ++id;
        }

        return uint32(id - 1);
    }


    function leaderboard(uint tokenId) public view returns (address[] memory board) {
        uint challengeId = tokenId >> 32;
        uint32 winners = winnerLevel(tokenId);
        board = new address[](winners);
        for (uint i = 1; i <= winners; ++i) {
            board[i - 1] = _ownerOf[(challengeId << 32) | i];
        }
    }

    function svg(uint tokenId) internal view returns (string memory) {
        uint32 thisLevel = uint32(tokenId);
        uint32 wLevel = winnerLevel(tokenId);
        uint32 rank = wLevel - thisLevel + 1;

        uint challengeId = tokenId >> 32;
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
}

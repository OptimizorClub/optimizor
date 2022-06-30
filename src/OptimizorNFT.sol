// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Challenge.sol";
import "./Time.sol";
import "./base64.sol";
import "./DataHelpers.sol";
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
        IChallenge target;
        uint32 level;
    }

    mapping (uint => Data) public challenges;
    mapping (uint => uint) public extraDetails;

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

        uint winnerTokenId = packTokenId(id, chl.level);
        (address winner, uint gasUsed) = extraDetailUnpacked(winnerTokenId);

        if (gasUsed != 0 && (gasUsed <= gas)) {
            revert NotOptimizor();
        }

        unchecked {
            ++chl.level;
        }

        uint tokenId = packTokenId(id, chl.level);
        ERC721._mint(recipient, tokenId);
        extraDetails[tokenId] = packExtraDetail(recipient, gas);
    }

    function leaderboard(uint tokenId) public view returns (address[] memory board) {
        (uint challengeId, ) = unpackTokenId(tokenId);
        uint32 winners = challenges[challengeId].level;
        board = new address[](winners);
        for (uint32 i = 1; i <= winners; ++i) {
            (address recipient, ) = extraDetailUnpacked(packTokenId(challengeId, i));
            board[i - 1] = recipient;
        }
    }

    function svg(uint tokenId) internal view returns (string memory) {
        TokenDetails memory details = tokenDetails(tokenId);

        uint32 wLevel = details.leaderLevel;
        uint32 rank = wLevel - details.level + 1;

        string memory name = details.challenge.name();

        NFTSVG.SVGParams memory svgParams = NFTSVG.SVGParams({
            projectName: "Optimizor",
            challengeName: name,
            // TODO should \/ be details.owner or details.recordHolder?
            holderAddr: NFTSVG.toHexString(uint(uint160(address(details.owner))), 20),
            challengeAddr: NFTSVG.toHexString(uint(uint160(address(details.challenge))), 20),
            gasUsed: details.gas,
            gasOpti: gasOptiPercentage(tokenId, details),
            overRange: int8(int256(uint256(keccak256(abi.encodePacked(tokenId))))) % 3,
            tokenId: tokenId,
            rank: rank,
            participants: wLevel,

            // Ideally these colors should not change if someone buys the nft,
            // since maybe they bought it because of the colors.
            // So we keep them based on the original record holder of this tokenId.
            color0: NFTSVG.tokenToColorHex(uint256(uint160(address(details.challenge))), 136),
            color1: NFTSVG.tokenToColorHex(uint256(uint160(details.recordHolder)), 136),
            color2: NFTSVG.tokenToColorHex(uint256(uint160(address(details.challenge))), 0),
            color3: NFTSVG.tokenToColorHex(uint256(uint160(details.recordHolder)), 0),

            x1: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(address(details.challenge))), 16, tokenId), 0, 255, 16, 274),
            y1: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(details.recordHolder)), 16, tokenId), 0, 255, 100, 484),
            x2: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(address(details.challenge))), 32, tokenId), 0, 255, 16, 274),
            y2: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(details.recordHolder)), 32, tokenId), 0, 255, 100, 484),
            x3: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(address(details.challenge))), 48, tokenId), 0, 255, 16, 274),
            y3: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(details.recordHolder)), 48, tokenId), 0, 255, 100, 484)
        });

        return NFTSVG.generateSVG(
            svgParams,
            details.challenge.svg(tokenId)
        );
    }

    function gasOptiPercentage(uint tokenId, TokenDetails memory details) internal view returns (uint) {
        // TODO this is a hack to show 99% improvement for the first holder
        if (details.level <= 1) {
            return 99;
        }

        TokenDetails memory prevDetails = tokenDetails(tokenId - 1);
        assert(prevDetails.gas > 0);

        return (details.gas * 100) / prevDetails.gas;
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


    function extraDetailUnpacked(uint256 tokenId) internal view returns (address recipient, uint32 gasUsed) {
        return unpackExtraDetail(extraDetails[tokenId]);
    }

    struct TokenDetails {
        uint challengeId;
        IChallenge challenge;

        uint32 leaderGas;
        uint32 leaderLevel;
        address leaderRecordHolder;
        address leaderOwner;

        uint32 gas;
        uint32 level;
        address recordHolder;
        address owner;
    }

    function tokenDetails(uint256 tokenId) public view returns (TokenDetails memory details) {
        (uint challengeId, uint32 level) = unpackTokenId(tokenId);
        (address recordHolder, uint32 gasUsed) = extraDetailUnpacked(tokenId);

        Data storage chl = challenges[challengeId];

        uint leaderTokenId = packTokenId(challengeId, chl.level);
        assert(_ownerOf[leaderTokenId] != address(0));
        (address winnerHolder, uint32 winnerGasUsed) = extraDetailUnpacked(leaderTokenId);

        details = TokenDetails(
            challengeId,
            chl.target,

            winnerGasUsed,
            chl.level,
            winnerHolder,
            _ownerOf[leaderTokenId],

            gasUsed,
            level,
            recordHolder,
            _ownerOf[tokenId]
        );
    }
}

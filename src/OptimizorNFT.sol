// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IChallenge.sol";
import "./Base64.sol";
import "./DataHelpers.sol";
import "./NFTSVG.sol";
import "./IAttribute.sol";
import "./TokenDetails.sol";
import "./HexString.sol";

import "solmate/auth/Owned.sol";
import "solmate/tokens/ERC721.sol";
import "solmate/utils/LibString.sol";

contract OptimizorNFT is ERC721 {
    // TODO add events

    // Invalid inputs
    error InvalidLevel(uint challengeId, uint32 level);

    // Challenge id errors
    error ChallengeNotFound(uint challengeId);

    struct Data {
        IChallenge target;
        uint32 level;
    }

    struct ExtraDetails {
        address code;
        address solver;
        uint32 gas;
    }

    mapping (uint => Data) public challenges;
    mapping (uint => ExtraDetails) public extraDetails;

    IAttribute[] public extraAttrs;

    constructor() ERC721("Optimizor Club", "OC") {
    }

    /*****************************
         PUBLIC VIEW FUNCTIONS
    ******************************/

    function tokenDetails(uint256 tokenId) public view returns (TokenDetails memory) {
        (uint challengeId, uint32 level) = unpackTokenId(tokenId);
        if (level == 0) revert InvalidLevel(challengeId, level);

        Data storage chl = challenges[challengeId];
        if (address(chl.target) == address(0)) revert ChallengeNotFound(challengeId);
        if (level > chl.level) revert InvalidLevel(challengeId, level);

        ExtraDetails storage details = extraDetails[tokenId];

        uint leaderTokenId = packTokenId(challengeId, chl.level);
        ExtraDetails storage leaderDetails = extraDetails[leaderTokenId];

        uint32 leaderLevel = chl.level;
        uint32 rank = leaderLevel - level + 1;

        // This means the first holder will have a 0% improvement.
        uint32 percentage = 0;
        if (level > 1) {
            ExtraDetails storage prevDetails = extraDetails[tokenId - 1];
            percentage = (details.gas * 100) / prevDetails.gas;
        }

        return TokenDetails(
            challengeId,
            chl.target,

            leaderDetails.gas,
            leaderLevel,
            leaderDetails.solver,
            _ownerOf[leaderTokenId],
            leaderDetails.code,

            details.gas,
            level,
            rank,
            percentage,
            details.solver,
            _ownerOf[tokenId],
            details.code
        );
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        TokenDetails memory details = tokenDetails(tokenId);
        return string.concat(
            'data:application/json;base64,',
            Base64.encode(
                bytes(string.concat(
                    '{',
                    '"name":" Optimizor Club: ', details.challenge.name(), '", ',
                    '"description":"', description(tokenId), '", ',
                    '"attributes": ', attributesJSON(tokenId), ',',
                    '"image": "data:image/svg+xml;base64,',
                    Base64.encode(bytes(svg(tokenId))),
                    '"',
                    '}'
                ))
            )
        );
    }

    function description(uint256 tokenId) public view returns (string memory) {
        TokenDetails memory details = tokenDetails(tokenId);
        return string.concat(
            "Art: ", details.challenge.description(), "\\n",
            leaderboardString(tokenId)
        );
    }

    function leaderboard(uint tokenId) public view returns (address[] memory board) {
        (uint challengeId, ) = unpackTokenId(tokenId);
        uint32 winners = challenges[challengeId].level;
        board = new address[](winners);
        for (uint32 i = 1; i <= winners; ++i) {
            ExtraDetails storage details = extraDetails[packTokenId(challengeId, i)];
            board[i - 1] = details.solver;
        }
    }

    function leaderboardString(uint tokenId) public view returns (string memory) {
        address[] memory leaders = leaderboard(tokenId);
        string memory leadersStr = "";
        uint lIdx = leaders.length;
        for (uint i = 0; i < leaders.length; ++i) {
            leadersStr = string.concat(
                "\\n",
                LibString.toString(lIdx),
                ". ",
                HexString.toHexString(uint(uint160(leaders[i])), 20),
                leadersStr
            );
            --lIdx;
        }
        return string.concat("Leaderboard:", leadersStr);
    }

    /*****************************
           INTERNAL HELPERS
    ******************************/

    function attributesJSON(uint tokenId) internal view returns (string memory attributes) {
        TokenDetails memory details = tokenDetails(tokenId);

        uint32 rank = details.rank;

        attributes = string.concat(
            '[',
            // With value/max_value this will be displayed as a bar.
            '{ "trait_type": "Rank", "value": ', LibString.toString(rank), ', "max_value": ', LibString.toString(details.leaderLevel), '}, ',
            '{ "trait_type": "Leader", "value": "', (rank == 1) ? "Yes" : "No", '"}, ',
            '{ "trait_type": "Top 3", "value": "', (rank <= 3) ? "Yes" : "No", '"}, ',
            '{ "trait_type": "Top 10", "value": "', (rank <= 10) ? "Yes" : "No", '"} '
        );

        for (uint i = 0; i < extraAttrs.length; ++i) {
            (string memory attr, string memory value) = extraAttrs[i].attribute(details);
            attributes = string.concat(
                attributes,
                ', { ',
                '"trait_type": "', attr, '", ',
                '"value": "', value, '",',
                '}'
            );
        }

        attributes = string.concat(
            attributes,
            ']'
        );
    }

    function svg(uint tokenId) internal view returns (string memory) {
        TokenDetails memory details = tokenDetails(tokenId);

        NFTSVG.SVGParams memory svgParams = NFTSVG.SVGParams({
            projectName: "Optimizor Club",
            challengeName: details.challenge.name(),
            // TODO should \/ be details.owner or details.solver?
            solverAddr: HexString.toHexString(uint(uint160(address(details.owner))), 20),
            challengeAddr: HexString.toHexString(uint(uint160(address(details.challenge))), 20),
            gasUsed: details.gas,
            gasOpti: details.improvementPercentage,
            overRange: int8(int256(uint256(keccak256(abi.encodePacked(tokenId))))) % 3,
            tokenId: tokenId,
            rank: details.rank,
            // The leader is the last player, e.g. its level equals the number of players.
            participants: details.leaderLevel,

            // Ideally these colors should not change if someone buys the nft,
            // since maybe they bought it because of the colors.
            // So we keep them based on the original record solver of this tokenId.
            color0: NFTSVG.tokenToColorHex(uint256(uint160(address(details.challenge))), 136),
            color1: NFTSVG.tokenToColorHex(uint256(uint160(details.solver)), 136),
            color2: NFTSVG.tokenToColorHex(uint256(uint160(address(details.challenge))), 0),
            color3: NFTSVG.tokenToColorHex(uint256(uint160(details.solver)), 0),

            x1: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(address(details.challenge))), 16, tokenId), 0, 255, 16, 274),
            y1: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(details.solver)), 16, tokenId), 0, 255, 100, 484),
            x2: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(address(details.challenge))), 32, tokenId), 0, 255, 16, 274),
            y2: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(details.solver)), 32, tokenId), 0, 255, 100, 484),
            x3: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(address(details.challenge))), 48, tokenId), 0, 255, 16, 274),
            y3: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(details.solver)), 48, tokenId), 0, 255, 100, 484)
        });

        return NFTSVG.generateSVG(
            svgParams,
            details.challenge.svg(tokenId)
        );
    }
}

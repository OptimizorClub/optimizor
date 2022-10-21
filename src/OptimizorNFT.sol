// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Base64.sol";
import "./DataHelpers.sol";
import "./NFTSVG.sol";
import "./IAttribute.sol";
import "./IChallenge.sol";
import "./TokenDetails.sol";
import "./HexString.sol";

import "solmate/auth/Owned.sol";
import "solmate/tokens/ERC721.sol";
import "solmate/utils/LibString.sol";

contract OptimizorNFT is ERC721 {
    // Commit errors
    error CodeAlreadySubmitted();
    error TooEarlyToChallenge();

    // Challenge id errors
    error ChallengeNotFound(uint challengeId);
    error ChallengeExists(uint challengeId);

    // Input filtering
    error InvalidRecipient();
    error CodeNotSubmitted();
    error NotPure();

    // Sadness
    error NotOptimizor();

    event ChallengeAdded(uint challengeId, IChallenge);

    // TODO add events

    struct Submission {
        address sender;
        uint96 blockNumber;
    }

    mapping (bytes32 => Submission) public submissions;

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

    constructor() ERC721("Test", "TTT") {
    }

    /*****************************
         PUBLIC VIEW FUNCTIONS
    ******************************/

    function tokenDetails(uint256 tokenId) public view returns (TokenDetails memory) {
        (uint challengeId, uint32 level) = unpackTokenId(tokenId);
        ExtraDetails storage details = extraDetails[tokenId];

        Data storage chl = challenges[challengeId];

        uint leaderTokenId = packTokenId(challengeId, chl.level);
        ExtraDetails storage leaderDetails = extraDetails[leaderTokenId];

        return TokenDetails(
            challengeId,
            chl.target,

            leaderDetails.gas,
            chl.level,
            leaderDetails.solver,
            _ownerOf[leaderTokenId],
            leaderDetails.code,

            details.gas,
            level,
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
                bytes.concat(
                    '{',
                    '"name":" Optimizor Club: ', bytes(details.challenge.name()), '", ',
                    '"description":"', bytes(description(tokenId)), '", ',
                    '"attributes": ', attributesJSON(tokenId), ',',
                    '"image": "data:image/svg+xml;base64,',
                    bytes(Base64.encode(bytes(svg(tokenId)))),
                    '"',
                    '}'
                )
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

    function attributesJSON(uint tokenId) internal view returns (bytes memory attributes) {
        TokenDetails memory details = tokenDetails(tokenId);

        uint32 wLevel = details.leaderLevel;
        uint32 rank = wLevel - details.level + 1;

        attributes = bytes.concat(
            '[',
            '{ "trait_type": "Leader", "value": "', bytes((rank == 1) ? "Yes" : "No"), '"}, ',
            '{ "trait_type": "Top 3", "value": "', bytes((rank <= 3) ? "Yes" : "No"), '"}, ',
            '{ "trait_type": "Top 10", "value": "', bytes((rank <= 10) ? "Yes" : "No"), '"} '
        );

        for (uint i = 0; i < extraAttrs.length; ++i) {
            (string memory attr, string memory value) = extraAttrs[i].attribute(details);
            attributes = bytes.concat(
                attributes,
                ', { ',
                '"trait_type": "', bytes(attr), '", ',
                '"value": "', bytes(value), '",',
                '}'
            );
        }

        attributes = bytes.concat(
            attributes,
            ']'
        );
    }

    function svg(uint tokenId) internal view returns (string memory) {
        TokenDetails memory details = tokenDetails(tokenId);

        uint32 wLevel = details.leaderLevel;
        uint32 rank = wLevel - details.level + 1;

        string memory name = details.challenge.name();

        NFTSVG.SVGParams memory svgParams = NFTSVG.SVGParams({
            projectName: "Optimizor Club",
            challengeName: name,
            // TODO should \/ be details.owner or details.solver?
            solverAddr: HexString.toHexString(uint(uint160(address(details.owner))), 20),
            challengeAddr: HexString.toHexString(uint(uint160(address(details.challenge))), 20),
            gasUsed: details.gas,
            gasOpti: gasOptiPercentage(tokenId, details),
            overRange: int8(int256(uint256(keccak256(abi.encodePacked(tokenId))))) % 3,
            tokenId: tokenId,
            rank: rank,
            participants: wLevel,

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

    function gasOptiPercentage(uint tokenId, TokenDetails memory details) internal view returns (uint) {
        // TODO this is a hack to show 99% improvement for the first holder
        if (details.level <= 1) {
            return 99;
        }

        TokenDetails memory prevDetails = tokenDetails(tokenId - 1);
        assert(prevDetails.gas > 0);

        return (details.gas * 100) / prevDetails.gas;
    }
}

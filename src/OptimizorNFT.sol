// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IChallenge} from "./IChallenge.sol";
import {Base64} from "./Base64.sol";
import {packTokenId, unpackTokenId} from "./DataHelpers.sol";
import {NFTSVG} from "./NFTSVG.sol";
import {IAttribute} from "./IAttribute.sol";
import {TokenDetails} from "./TokenDetails.sol";
import {HexString} from "./HexString.sol";

import {ERC721} from "solmate/tokens/ERC721.sol";
import {LibString} from "solmate/utils/LibString.sol";

contract OptimizorNFT is ERC721 {
    // TODO add events

    // Invalid inputs
    error InvalidSolutionId(uint256 challengeId, uint32 solutionId);

    // Challenge id errors
    error ChallengeNotFound(uint256 challengeId);

    struct ChallengeInfo {
        IChallenge target;
        uint32 solutions;
    }

    struct ExtraDetails {
        address code;
        address solver;
        uint32 gas;
    }

    mapping(uint256 => ChallengeInfo) public challenges;
    mapping(uint256 => ExtraDetails) public extraDetails;

    IAttribute[] public extraAttrs;

    constructor() ERC721("Optimizor Club", "OC") {}

    /**
     *
     *      PUBLIC VIEW FUNCTIONS
     *
     */

    function contractURI() external pure returns (string memory) {
        return
        "data:application/json;base64,eyJuYW1lIjoiT3B0aW1pem9yIENsdWIiImRlc2NyaXB0aW9uIjoiVGhlIE9wdGltaXpvciBDbHViIE5GVCBjb2xsZWN0aW9uIHJld2FyZHMgZ2FzIGVmZmljaWVudCBwZW9wbGUgYW5kIG1hY2hpbmVzIGJ5IG1pbnRpbmcgbmV3IGl0ZW1zIHdoZW5ldmVyIGEgY2hlYXBlciBzb2x1dGlvbiBpcyBzdWJtaXR0ZWQgZm9yIGEgY2VydGFpbiBjaGFsbGVuZ2UuIiJpbWFnZSI6IiwgbG9nbywgIiJleHRlcm5hbF9saW5rIjoiaHR0cHM6Ly9vcHRpbWl6b3IuY2x1Yi8ifQ==";
    }

    function tokenDetails(uint256 tokenId) public view returns (TokenDetails memory) {
        (uint256 challengeId, uint32 solutionId) = unpackTokenId(tokenId);
        if (solutionId == 0) revert InvalidSolutionId(challengeId, solutionId);

        ChallengeInfo storage chl = challenges[challengeId];
        if (address(chl.target) == address(0)) revert ChallengeNotFound(challengeId);
        if (solutionId > chl.solutions) revert InvalidSolutionId(challengeId, solutionId);

        ExtraDetails storage details = extraDetails[tokenId];

        uint256 leaderTokenId = packTokenId(challengeId, chl.solutions);
        ExtraDetails storage leaderDetails = extraDetails[leaderTokenId];

        uint32 leaderSolutionId = chl.solutions;
        uint32 rank = leaderSolutionId - solutionId + 1;

        // This means the first holder will have a 0% improvement.
        uint32 percentage = 0;
        if (solutionId > 1) {
            ExtraDetails storage prevDetails = extraDetails[tokenId - 1];
            percentage = (details.gas * 100) / prevDetails.gas;
        }

        return TokenDetails({
            challengeId: challengeId,
            challenge: chl.target,
            leaderGas: leaderDetails.gas,
            leaderSolutionId: leaderSolutionId,
            leaderSolver: leaderDetails.solver,
            leaderOwner: _ownerOf[leaderTokenId],
            leaderSubmission: leaderDetails.code,
            gas: details.gas,
            solutionId: solutionId,
            rank: rank,
            improvementPercentage: percentage,
            solver: details.solver,
            owner: _ownerOf[tokenId],
            submission: details.code
        });
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        TokenDetails memory details = tokenDetails(tokenId);

        string memory description = string.concat(details.challenge.description(), "\\n", leaderboardString(tokenId));

        return string.concat(
            "data:application/json;base64,",
            Base64.encode(
                bytes(
                    string.concat(
                        "{",
                        '"name":"Optimizor Club: ',
                        details.challenge.name(),
                        '",',
                        '"description":"',
                        description,
                        '",',
                        '"attributes":',
                        attributesJSON(details),
                        ",",
                        '"image":"data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg(tokenId, details))),
                        '"',
                        "}"
                    )
                )
            )
        );
    }

    function leaderboard(uint256 tokenId) public view returns (address[] memory board) {
        (uint256 challengeId,) = unpackTokenId(tokenId);
        uint32 winners = challenges[challengeId].solutions;
        board = new address[](winners);
        for (uint32 i = 1; i <= winners; ++i) {
            ExtraDetails storage details = extraDetails[packTokenId(challengeId, i)];
            board[i - 1] = details.solver;
        }
    }

    /**
     *
     *        INTERNAL HELPERS
     *
     */

    function leaderboardString(uint256 tokenId) internal view returns (string memory) {
        address[] memory leaders = leaderboard(tokenId);
        string memory leadersStr = "";
        uint256 lIdx = leaders.length;
        for (uint256 i = 0; i < leaders.length; ++i) {
            leadersStr = string.concat(
                "\\n",
                LibString.toString(lIdx),
                ". ",
                HexString.toHexString(uint256(uint160(leaders[i])), 20),
                leadersStr
            );
            --lIdx;
        }
        return string.concat("Leaderboard:", leadersStr);
    }

    function attributesJSON(TokenDetails memory details) internal view returns (string memory attributes) {
        uint32 rank = details.rank;

        // Core details.
        attributes = string.concat(
            "[",
            '{"trait_type":"Challenge","value":"',
            details.challenge.name(),
            '"},',
            '{"trait_type":"Gas used","value":',
            LibString.toString(details.gas),
            ',"display_type":"number"},',
            '{"trait_type":"Code size","value":',
            LibString.toString(details.submission.code.length),
            ',"display_type":"number"},',
            '{"trait_type":"Improvement percentage","value":"',
            LibString.toString(details.improvementPercentage),
            '%"},',
            '{"trait_type":"Solver","value":"',
            HexString.toHexString(uint256(uint160(details.solver)), 20),
            '"},'
        );

        // Standing.
        attributes = string.concat(
            attributes,
            // With value/max_value this will be displayed as a bar.
            '{"trait_type":"Rank","value":',
            LibString.toString(rank),
            ',"max_value":',
            LibString.toString(details.leaderSolutionId),
            "},",
            '{"trait_type":"Leader","value":"',
            (rank == 1) ? "Yes" : "No",
            '"},',
            '{"trait_type":"Top 3","value":"',
            (rank <= 3) ? "Yes" : "No",
            '"},',
            '{"trait_type":"Top 10","value":"',
            (rank <= 10) ? "Yes" : "No",
            '"}'
        );

        for (uint256 i = 0; i < extraAttrs.length; ++i) {
            (string memory attr, string memory value) = extraAttrs[i].attribute(details);
            attributes = string.concat(attributes, ",{", '"trait_type":"', attr, '",', '"value":"', value, '",', "}");
        }

        attributes = string.concat(attributes, "]");
    }

    function svg(uint256 tokenId, TokenDetails memory details) internal view returns (string memory) {
        uint256 grad_rgb = 0;
        if (details.rank > 10) {
            grad_rgb = 0xbebebe;
        } else if (details.rank > 3) {
            uint256 fRank;
            uint256 init = 40;
            uint256 factor = 15;
            unchecked {
                fRank = init + details.rank * factor;
            }
            grad_rgb = (uint256(fRank) << 16) | (uint256(fRank) << 8) | uint256(fRank);
        }

        NFTSVG.SVGParams memory svgParams = NFTSVG.SVGParams({
            projectName: "Optimizor Club",
            challengeName: details.challenge.name(),
            // TODO should \/ be details.owner or details.solver?
            solverAddr: HexString.toHexString(uint256(uint160(address(details.owner))), 20),
            challengeAddr: HexString.toHexString(uint256(uint160(address(details.challenge))), 20),
            gasUsed: details.gas,
            gasOpti: details.improvementPercentage,
            overRange: int8(int256(uint256(keccak256(abi.encodePacked(tokenId))))) % 3,
            tokenId: tokenId,
            rank: details.rank,
            // The leader is the last player, e.g. its solution id equals the number of players.
            participants: details.leaderSolutionId,
            color0: NFTSVG.tokenToColorHex(grad_rgb, 0),
            color1: NFTSVG.tokenToColorHex(grad_rgb, 0),
            color2: NFTSVG.tokenToColorHex(grad_rgb, 0),
            color3: NFTSVG.tokenToColorHex(grad_rgb, 0),
            x1: NFTSVG.scale(
                NFTSVG.getCircleCoord(uint256(uint160(address(details.challenge))), 16, tokenId), 0, 255, 16, 274
                ),
            y1: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(details.solver)), 16, tokenId), 0, 255, 100, 484),
            x2: NFTSVG.scale(
                NFTSVG.getCircleCoord(uint256(uint160(address(details.challenge))), 32, tokenId), 0, 255, 16, 274
                ),
            y2: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(details.solver)), 32, tokenId), 0, 255, 100, 484),
            x3: NFTSVG.scale(
                NFTSVG.getCircleCoord(uint256(uint160(address(details.challenge))), 48, tokenId), 0, 255, 16, 274
                ),
            y3: NFTSVG.scale(NFTSVG.getCircleCoord(uint256(uint160(details.solver)), 48, tokenId), 0, 255, 100, 484)
        });

        return NFTSVG.generateSVG(svgParams, details.challenge.svg(tokenId));
    }
}

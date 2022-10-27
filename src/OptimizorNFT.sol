// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IChallenge} from "src/IChallenge.sol";
import {Base64} from "src/Base64.sol";
import {packTokenId, unpackTokenId} from "src/DataHelpers.sol";
import {NFTSVG} from "src/NFTSVG.sol";
import {IAttribute} from "src/IAttribute.sol";
import {TokenDetails} from "src/TokenDetails.sol";
import {HexString} from "src/HexString.sol";

import {ERC721} from "solmate/tokens/ERC721.sol";
import {LibString} from "solmate/utils/LibString.sol";

contract OptimizorNFT is ERC721 {
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

    function contractURI() external pure returns (string memory) {
        return
        "data:application/json;base64,eyJuYW1lIjoiT3B0aW1pem9yIENsdWIiImRlc2NyaXB0aW9uIjoiVGhlIE9wdGltaXpvciBDbHViIE5GVCBjb2xsZWN0aW9uIHJld2FyZHMgZ2FzIGVmZmljaWVudCBwZW9wbGUgYW5kIG1hY2hpbmVzIGJ5IG1pbnRpbmcgbmV3IGl0ZW1zIHdoZW5ldmVyIGEgY2hlYXBlciBzb2x1dGlvbiBpcyBzdWJtaXR0ZWQgZm9yIGEgY2VydGFpbiBjaGFsbGVuZ2UuIiJpbWFnZSI6Ijxzdmcgd2lkdGg9IjMwOC41MzEiIGhlaWdodD0iMTEyLjAzMyIgdmlld0JveD0iMCAwIDgxLjYzMiAyOS42NDIiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZD0iTTEzLjA5MiA1LjYyM2gtLjYyMlY1SDYuMjQ0di42MjNoLjYyM3YuNjIyaC0uNjIzdi42MjNoLS42MjJ2LS42MjNoLS42MjN2Ni4yMjZoLjYyM3YuNjIyaC42MjJ2LjYyM2g2LjIyNnYtLjYyM2guNjIydi0uNjIyaC42MjNWNi4yNDVoLS42MjN6bS0zLjczNSA1LjYwM1Y2Ljg2OGgxLjg2OHY0LjM1OHpNMjEuODEgNy40OXYtLjYyMmgtLjYyMnYtLjYyM2gtNS42MDN2LjYyM2gxLjI0NXYuNjIyaC0uNjIzdi42MjNoLS42MjJWNi44NjhoLS42MjN2Ni4yMjVoLjYyM3YuNjIzaDIuNDl2LS42MjNoLjYyMnYtMS44NjdoMi40OXYtLjYyM2guNjIzVjkuOThoLjYyMlY3LjQ5em0tMy4xMTMuNjIzaDEuMjQ2VjkuOThoLTEuMjQ2em0xMS44MzYtMS44NjhoLTYuMjI1di42MjNoMS4yNDV2LjYyMmgtLjYyM3YuNjIzaC0uNjIydi42MjJoMS4yNDV2NC4zNThoLjYyMnYuNjIzaDIuNDl2LS42MjNoLjYyM1Y4LjczNmgxLjI0NXYtLjYyM2guNjIzVjYuODY4aC0uNjIzem0tNi4yMjUuNjIzaC0uNjIzdjEuMjQ1aC42MjN6bTExLjIxMy0uNjIzaC0yLjQ5di42MjNoMS4yNDV2LjYyMmgtLjYyM3YuNjIzaC0uNjIyVjYuODY4aC0uNjIzdjYuMjI1aC42MjN2LjYyM2gyLjQ5di0uNjIzaC42MjJWNi44NjhoLS42MjJ6bTkuMzQgMGgtMS4yNDZ2LjYyM2gtLjYyM3YxLjI0NWgtLjYyMnYuNjIyaC0uNjIzdi0uNjIyaC0uNjIyVjYuODY4aC0uNjIzdi0uNjIzaC0yLjQ5di42MjNoMS4yNDV2LjYyMmgtLjYyMnYuNjIzaC0uNjIzVjYuODY4aC0uNjIzdjYuMjI1aC42MjN2LjYyM2gyLjQ5di0uNjIzaC42MjN2LTIuNDloLjYyMnYuNjIzaC42MjN2LS42MjNoLjYyMnYyLjQ5aC42MjN2LjYyM2gxLjI0NXYtLjYyM2guNjIzVjYuODY4aC0uNjIzem00Ljk4NCAwaC0yLjQ5di42MjNINDguNnYuNjIyaC0uNjIydi42MjNoLS42MjNWNi44NjhoLS42MjJ2Ni4yMjVoLjYyMnYuNjIzaDIuNDl2LS42MjNoLjYyM1Y2Ljg2OGgtLjYyM3ptOC43MTcuNjIzdi0uNjIzaC02LjIyNXYuNjIzaDEuMjQ1di42MjJoLS42MjN2LjYyM2gtLjYyMnYuNjIyaDIuNDl2LjYyM2gtLjYyM3YuNjIyaC0uNjIydi42MjNoLS42MjN2LjYyM2gtLjYyMnYuNjIyaC0uNjIzdjEuMjQ1aC42MjN2LjYyM2g2LjIyNXYtLjYyM2guNjIzdi0xLjg2N2gtLjYyM3YtLjYyM2gtMS44NjdWOS45OGguNjIydi0uNjIyaC42MjJ2LS42MjNoLjYyM3YtLjYyMmguNjIzVjYuODY4em0tNi4yMjUgMGgtLjYyM3YxLjI0NWguNjIzem0xNC45NDggMGgtLjYyM3YtLjYyM2gtNC45OHYuNjIzaC42MjN2LjYyMmgtLjYyM3YuNjIzaC0uNjIyVjcuNDloLS42MjN2NC45OGguNjIzdi42MjNoLjYyMnYuNjIzaDQuOTh2LS42MjNoLjYyM3YtLjYyMmguNjIyVjcuNDloLS42MjJ6bS0xLjI0NSA0LjM1OGgtMS44NjhWOC4xMTNoMS44Njh6bTkuOTY4LTQuMzU4aC0uNjIzdi0uNjIzaC01LjYwM3YuNjIzaDEuMjQ1di42MjJoLS42MjJ2LjYyM2gtLjYyM1Y2Ljg2OGgtLjYyMnY2LjIyNWguNjIydi42MjNoMi40OXYtLjYyM2guNjIzdi0xLjg2N2guNjIzdi42MjJoLjYyMnYuNjIzaC42MjN2LjYyMmguNjIydi42MjNoLjYyM3YtLjYyM2guNjIydi0xLjg2N2gtLjYyMnYtLjYyM2gtLjYyM1Y5Ljk4aC42MjN2LS42MjJoLjYyMlY3LjQ5aC0uNjIyem0tMy4xMTMgMS44Njh2LS42MjNoMS44Njh2LjYyMnptLTQwLjE4NyA3LjE5SDI1Ljg2di42MjJoLjYyMnYuNjIzaC0uNjIydi42MjJoLS42MjN2LS42MjJoLS42MjJ2Ni4yMjVoLjYyMnYuNjIzaC42MjN2LjYyMmg2Ljg0OHYtLjYyMmguNjIzdi0xLjI0NWgtLjYyM3YtLjYyM2gtMy43MzZ2LTQuMzU4aDMuNzM2di0uNjIyaC42MjN2LS42MjNoLS42MjN6bTguMDk1IDYuMjI1aC0yLjQ5di00LjM1OGgtLjYyM3YtLjYyMkgzNS4ydi42MjJoMS4yNDZ2LjYyM2gtLjYyM3YuNjIySDM1LjJ2LTEuMjQ1aC0uNjIydjYuMjI2aC42MjJ2LjYyMmg1LjYwM3YtLjYyMmguNjIzdi0xLjI0NWgtLjYyM3ptOC43MjUtNC45OGgtMS4yNDV2LjYyMmgtLjYyMnY0LjM1OGgtMS4yNDV2LTQuMzU4aC0uNjIzdi0uNjIyaC0yLjQ5di42MjJoMS4yNDV2LjYyM2gtLjYyMnYuNjIzaC0uNjIzdi0xLjI0NmgtLjYyMnY1LjYwM2guNjIydi42MjNoLjYyM3YuNjIyaDQuOTh2LS42MjJoLjYyMnYtLjYyM2guNjIzdi01LjYwM2gtLjYyM3ptOC43MjMuNjIyaC0uNjIydi0uNjIyaC01LjYwM3YuNjIyaDEuMjQ1di42MjNoLS42MjN2LjYyM2gtLjYyMnYtMS4yNDZoLS42MjJ2Ni4yMjZoLjYyMnYuNjIyaDUuNjAzdi0uNjIyaC42MjJ2LS42MjNoLjYyM3YtMi40OWgtLjYyM3YtLjYyMmguNjIzdi0xLjg2OGgtLjYyM3ptLTEuMjQ1IDQuMzU4SDU1LjE0di0uNjIyaDEuODY3em0tMS44NjctMi40OXYtLjYyMmgxLjg2N3YuNjIyeiIgc3R5bGU9ImZpbGw6IzY2NiIvPjwvc3ZnPiIiZXh0ZXJuYWxfbGluayI6Imh0dHBzOi8vb3B0aW1pem9yLmNsdWIvIn0=";
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

    function leaderboardString(uint256 tokenId) private view returns (string memory) {
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

    function attributesJSON(TokenDetails memory details) private view returns (string memory attributes) {
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

    function svg(uint256 tokenId, TokenDetails memory details) private view returns (string memory) {
        uint256 gradRgb = 0;
        if (details.rank > 10) {
            gradRgb = 0xbebebe;
        } else if (details.rank > 3) {
            uint256 fRank;
            uint256 init = 40;
            uint256 factor = 15;
            unchecked {
                fRank = init + details.rank * factor;
            }
            gradRgb = (uint256(fRank) << 16) | (uint256(fRank) << 8) | uint256(fRank);
        }
        string memory gradRgbHex = HexString.toHexStringNoPrefix(gradRgb, 3);

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
            color0: gradRgbHex,
            color1: gradRgbHex,
            color2: gradRgbHex,
            color3: gradRgbHex,
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

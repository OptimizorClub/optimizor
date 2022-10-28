// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IChallenge} from "src/IChallenge.sol";
import {Base64} from "src/Base64.sol";
import {packTokenId, unpackTokenId} from "src/DataHelpers.sol";
import {NFTSVG} from "src/NFTSVG.sol";
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
        /// The address of the challenge contract.
        IChallenge target;
        /// The number of valid solutions so far.
        uint32 solutions;
    }

    struct ExtraDetails {
        /// The address of the solution contract.
        address code;
        /// The address of the challenger who called `challenge`.
        address solver;
        /// The amount of gas spent by this solution.
        uint32 gas;
    }

    /// Maps challenge ids to their contracts and amount of solutions.
    mapping(uint256 => ChallengeInfo) public challenges;

    /// Maps token ids to extra details about the solution.
    mapping(uint256 => ExtraDetails) public extraDetails;

    constructor() ERC721("Optimizor Club", "OC") {}

    function contractURI() external pure returns (string memory) {
        return
        "data:application/json;base64,eyJuYW1lIjoiT3B0aW1pem9yIENsdWIiLCJkZXNjcmlwdGlvbiI6IlRoZSBPcHRpbWl6b3IgQ2x1YiBORlQgY29sbGVjdGlvbiByZXdhcmRzIGdhcyBlZmZpY2llbnQgcGVvcGxlIGFuZCBtYWNoaW5lcyBieSBtaW50aW5nIG5ldyBpdGVtcyB3aGVuZXZlciBhIGNoZWFwZXIgc29sdXRpb24gaXMgc3VibWl0dGVkIGZvciBhIGNlcnRhaW4gY2hhbGxlbmdlLiIsImltYWdlIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCM2FXUjBhRDBpTXpBNExqVXpNU0lnYUdWcFoyaDBQU0l4TVRJdU1ETXpJaUIyYVdWM1FtOTRQU0l3SURBZ09ERXVOak15SURJNUxqWTBNaUlnZUcxc2JuTTlJbWgwZEhBNkx5OTNkM2N1ZHpNdWIzSm5Mekl3TURBdmMzWm5JajQ4Y0dGMGFDQmtQU0pOTVRNdU1Ea3lJRFV1TmpJemFDMHVOakl5VmpWSU5pNHlORFIyTGpZeU0yZ3VOakl6ZGk0Mk1qSm9MUzQyTWpOMkxqWXlNMmd0TGpZeU1uWXRMall5TTJndExqWXlNM1kyTGpJeU5tZ3VOakl6ZGk0Mk1qSm9Mall5TW5ZdU5qSXphRFl1TWpJMmRpMHVOakl6YUM0Mk1qSjJMUzQyTWpKb0xqWXlNMVkyTGpJME5XZ3RMall5TTNwdExUTXVOek0xSURVdU5qQXpWall1T0RZNGFERXVPRFk0ZGpRdU16VTRlazB5TVM0NE1TQTNMalE1ZGkwdU5qSXlhQzB1TmpJeWRpMHVOakl6YUMwMUxqWXdNM1l1TmpJemFERXVNalExZGk0Mk1qSm9MUzQyTWpOMkxqWXlNMmd0TGpZeU1sWTJMamcyT0dndExqWXlNM1kyTGpJeU5XZ3VOakl6ZGk0Mk1qTm9NaTQwT1hZdExqWXlNMmd1TmpJeWRpMHhMamcyTjJneUxqUTVkaTB1TmpJemFDNDJNak5XT1M0NU9HZ3VOakl5VmpjdU5EbDZiUzB6TGpFeE15NDJNak5vTVM0eU5EWldPUzQ1T0dndE1TNHlORFo2YlRFeExqZ3pOaTB4TGpnMk9HZ3ROaTR5TWpWMkxqWXlNMmd4TGpJME5YWXVOakl5YUMwdU5qSXpkaTQyTWpOb0xTNDJNakoyTGpZeU1tZ3hMakkwTlhZMExqTTFPR2d1TmpJeWRpNDJNak5vTWk0ME9YWXRMall5TTJndU5qSXpWamd1TnpNMmFERXVNalExZGkwdU5qSXphQzQyTWpOV05pNDROamhvTFM0Mk1qTjZiUzAyTGpJeU5TNDJNak5vTFM0Mk1qTjJNUzR5TkRWb0xqWXlNM3B0TVRFdU1qRXpMUzQyTWpOb0xUSXVORGwyTGpZeU0yZ3hMakkwTlhZdU5qSXlhQzB1TmpJemRpNDJNak5vTFM0Mk1qSldOaTQ0Tmpob0xTNDJNak4yTmk0eU1qVm9Mall5TTNZdU5qSXphREl1TkRsMkxTNDJNak5vTGpZeU1sWTJMamcyT0dndExqWXlNbnB0T1M0ek5DQXdhQzB4TGpJME5uWXVOakl6YUMwdU5qSXpkakV1TWpRMWFDMHVOakl5ZGk0Mk1qSm9MUzQyTWpOMkxTNDJNakpvTFM0Mk1qSldOaTQ0Tmpob0xTNDJNak4yTFM0Mk1qTm9MVEl1TkRsMkxqWXlNMmd4TGpJME5YWXVOakl5YUMwdU5qSXlkaTQyTWpOb0xTNDJNak5XTmk0NE5qaG9MUzQyTWpOMk5pNHlNalZvTGpZeU0zWXVOakl6YURJdU5EbDJMUzQyTWpOb0xqWXlNM1l0TWk0ME9XZ3VOakl5ZGk0Mk1qTm9Mall5TTNZdExqWXlNMmd1TmpJeWRqSXVORGxvTGpZeU0zWXVOakl6YURFdU1qUTFkaTB1TmpJemFDNDJNak5XTmk0NE5qaG9MUzQyTWpONmJUUXVPVGcwSURCb0xUSXVORGwyTGpZeU0wZzBPQzQyZGk0Mk1qSm9MUzQyTWpKMkxqWXlNMmd0TGpZeU0xWTJMamcyT0dndExqWXlNblkyTGpJeU5XZ3VOakl5ZGk0Mk1qTm9NaTQwT1hZdExqWXlNMmd1TmpJelZqWXVPRFk0YUMwdU5qSXplbTA0TGpjeE55NDJNak4yTFM0Mk1qTm9MVFl1TWpJMWRpNDJNak5vTVM0eU5EVjJMall5TW1ndExqWXlNM1l1TmpJemFDMHVOakl5ZGk0Mk1qSm9NaTQwT1hZdU5qSXphQzB1TmpJemRpNDJNakpvTFM0Mk1qSjJMall5TTJndExqWXlNM1l1TmpJemFDMHVOakl5ZGk0Mk1qSm9MUzQyTWpOMk1TNHlORFZvTGpZeU0zWXVOakl6YURZdU1qSTFkaTB1TmpJemFDNDJNak4yTFRFdU9EWTNhQzB1TmpJemRpMHVOakl6YUMweExqZzJOMVk1TGprNGFDNDJNakoyTFM0Mk1qSm9Mall5TW5ZdExqWXlNMmd1TmpJemRpMHVOakl5YUM0Mk1qTldOaTQ0TmpoNmJTMDJMakl5TlNBd2FDMHVOakl6ZGpFdU1qUTFhQzQyTWpONmJURTBMamswT0NBd2FDMHVOakl6ZGkwdU5qSXphQzAwTGprNGRpNDJNak5vTGpZeU0zWXVOakl5YUMwdU5qSXpkaTQyTWpOb0xTNDJNakpXTnk0ME9XZ3RMall5TTNZMExqazRhQzQyTWpOMkxqWXlNMmd1TmpJeWRpNDJNak5vTkM0NU9IWXRMall5TTJndU5qSXpkaTB1TmpJeWFDNDJNakpXTnk0ME9XZ3RMall5TW5wdExURXVNalExSURRdU16VTRhQzB4TGpnMk9GWTRMakV4TTJneExqZzJPSHB0T1M0NU5qZ3ROQzR6TlRob0xTNDJNak4yTFM0Mk1qTm9MVFV1TmpBemRpNDJNak5vTVM0eU5EVjJMall5TW1ndExqWXlNbll1TmpJemFDMHVOakl6VmpZdU9EWTRhQzB1TmpJeWRqWXVNakkxYUM0Mk1qSjJMall5TTJneUxqUTVkaTB1TmpJemFDNDJNak4yTFRFdU9EWTNhQzQyTWpOMkxqWXlNbWd1TmpJeWRpNDJNak5vTGpZeU0zWXVOakl5YUM0Mk1qSjJMall5TTJndU5qSXpkaTB1TmpJemFDNDJNakoyTFRFdU9EWTNhQzB1TmpJeWRpMHVOakl6YUMwdU5qSXpWamt1T1Rob0xqWXlNM1l0TGpZeU1tZ3VOakl5VmpjdU5EbG9MUzQyTWpKNmJTMHpMakV4TXlBeExqZzJPSFl0TGpZeU0yZ3hMamcyT0hZdU5qSXllbTB0TkRBdU1UZzNJRGN1TVRsSU1qVXVPRFoyTGpZeU1tZ3VOakl5ZGk0Mk1qTm9MUzQyTWpKMkxqWXlNbWd0TGpZeU0zWXRMall5TW1ndExqWXlNblkyTGpJeU5XZ3VOakl5ZGk0Mk1qTm9Mall5TTNZdU5qSXlhRFl1T0RRNGRpMHVOakl5YUM0Mk1qTjJMVEV1TWpRMWFDMHVOakl6ZGkwdU5qSXphQzB6TGpjek5uWXROQzR6TlRob015NDNNeloyTFM0Mk1qSm9Mall5TTNZdExqWXlNMmd0TGpZeU0zcHRPQzR3T1RVZ05pNHlNalZvTFRJdU5EbDJMVFF1TXpVNGFDMHVOakl6ZGkwdU5qSXlTRE0xTGpKMkxqWXlNbWd4TGpJME5uWXVOakl6YUMwdU5qSXpkaTQyTWpKSU16VXVNbll0TVM0eU5EVm9MUzQyTWpKMk5pNHlNalpvTGpZeU1uWXVOakl5YURVdU5qQXpkaTB1TmpJeWFDNDJNak4yTFRFdU1qUTFhQzB1TmpJemVtMDRMamN5TlMwMExqazRhQzB4TGpJME5YWXVOakl5YUMwdU5qSXlkalF1TXpVNGFDMHhMakkwTlhZdE5DNHpOVGhvTFM0Mk1qTjJMUzQyTWpKb0xUSXVORGwyTGpZeU1tZ3hMakkwTlhZdU5qSXphQzB1TmpJeWRpNDJNak5vTFM0Mk1qTjJMVEV1TWpRMmFDMHVOakl5ZGpVdU5qQXphQzQyTWpKMkxqWXlNMmd1TmpJemRpNDJNakpvTkM0NU9IWXRMall5TW1ndU5qSXlkaTB1TmpJemFDNDJNak4yTFRVdU5qQXphQzB1TmpJemVtMDRMamN5TXk0Mk1qSm9MUzQyTWpKMkxTNDJNakpvTFRVdU5qQXpkaTQyTWpKb01TNHlORFYyTGpZeU0yZ3RMall5TTNZdU5qSXphQzB1TmpJeWRpMHhMakkwTm1ndExqWXlNblkyTGpJeU5tZ3VOakl5ZGk0Mk1qSm9OUzQyTUROMkxTNDJNakpvTGpZeU1uWXRMall5TTJndU5qSXpkaTB5TGpRNWFDMHVOakl6ZGkwdU5qSXlhQzQyTWpOMkxURXVPRFk0YUMwdU5qSXplbTB0TVM0eU5EVWdOQzR6TlRoSU5UVXVNVFIyTFM0Mk1qSm9NUzQ0TmpkNmJTMHhMamcyTnkweUxqUTVkaTB1TmpJeWFERXVPRFkzZGk0Mk1qSjZJaUJ6ZEhsc1pUMGlabWxzYkRvak5qWTJJaTgrUEM5emRtYysiLCJleHRlcm5hbF9saW5rIjoiaHR0cHM6Ly9vcHRpbWl6b3IuY2x1Yi8ifQ==";
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

        attributes = string.concat(
            '[{"trait_type":"Challenge","value":"',
            details.challenge.name(),
            '"},{"trait_type":"Gas used","value":',
            LibString.toString(details.gas),
            ',"display_type":"number"},{"trait_type":"Code size","value":',
            LibString.toString(details.submission.code.length),
            ',"display_type":"number"},{"trait_type":"Improvement percentage","value":"',
            LibString.toString(details.improvementPercentage),
            '%"},{"trait_type":"Solver","value":"',
            HexString.toHexString(uint256(uint160(details.solver)), 20),
            // With value/max_value this will be displayed as a bar.
            '"},{"trait_type":"Rank","value":',
            LibString.toString(rank),
            ',"max_value":',
            LibString.toString(details.leaderSolutionId),
            '},{"trait_type":"Leader","value":"',
            (rank == 1) ? "Yes" : "No",
            '"},{"trait_type":"Top 3","value":"',
            (rank <= 3) ? "Yes" : "No",
            '"},{"trait_type":"Top 10","value":"',
            (rank <= 10) ? "Yes" : "No",
            '"}]'
        );
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

        NFTSVG.SVGParams memory svgParams = NFTSVG.SVGParams({
            projectName: "Optimizor Club",
            challengeName: details.challenge.name(),
            solverAddr: HexString.toHexString(uint256(uint160(address(details.owner))), 20),
            challengeAddr: HexString.toHexString(uint256(uint160(address(details.challenge))), 20),
            gasUsed: details.gas,
            gasOpti: details.improvementPercentage,
            tokenId: tokenId,
            rank: details.rank,
            // The leader is the last player, e.g. its solution id equals the number of players.
            participants: details.leaderSolutionId,
            color: HexString.toHexStringNoPrefix(gradRgb, 3),
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

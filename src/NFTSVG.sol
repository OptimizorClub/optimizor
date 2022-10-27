// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.15;

import {Base64} from "src/Base64.sol";
import {HexString} from "src/HexString.sol";

import {LibString} from "solmate/utils/LibString.sol";

/// @title NFTSVG
/// @notice Provides a function for generating an SVG associated with a Uniswap NFT
library NFTSVG {
    struct SVGParams {
        string projectName;
        string challengeName;
        string solverAddr;
        string challengeAddr;
        uint256 gasUsed;
        uint256 gasOpti;
        int8 overRange;
        uint256 tokenId;
        uint32 rank;
        uint32 participants;
        string color0;
        string color1;
        string color2;
        string color3;
        string x1;
        string y1;
        string x2;
        string y2;
        string x3;
        string y3;
    }

    function generateSVG(SVGParams memory params, string memory challengeSVG)
        internal
        pure
        returns (string memory svg)
    {
        /*
        address: "0xe8ab59d3bcde16a29912de83a90eb39628cfc163",
        msg: "Forged in SVG for Uniswap in 2021 by 0xe8ab59d3bcde16a29912de83a90eb39628cfc163",
        sig: "0x2df0e99d9cbfec33a705d83f75666d98b22dea7c1af412c584f7d626d83f02875993df740dc87563b9c73378f8462426da572d7989de88079a382ad96c57b68d1b",
        version: "2"
         */
        return string.concat(
            generateSVGDefs(params),
            generateSVGBorderText(params.projectName, params.challengeName, params.solverAddr, params.challengeAddr),
            generateSVGCardMantle(params.challengeName, params.challengeAddr, params.rank, params.participants),
            generateRankBorder(params.rank),
            generateSvgCurve(params.overRange, challengeSVG),
            generateSVGPositionDataAndLocationCurve(LibString.toString(params.tokenId), params.gasUsed, params.gasOpti),
            generateSVGRareSparkle(params.rank),
            "</svg>"
        );
    }

    function generateSVGDefs(SVGParams memory params) private pure returns (string memory svg) {
        svg = string.concat(
            '<svg width="290" height="500" viewBox="0 0 290 500" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
            "<defs>",
            '<filter id="f1"><feImage result="p0" xlink:href="data:image/svg+xml;base64,',
            Base64.encode(
                bytes(
                    string.concat(
                        "<svg width='290' height='500' viewBox='0 0 290 500' xmlns='http://www.w3.org/2000/svg'><rect width='290px' height='500px' fill='#",
                        params.color0,
                        "'/></svg>"
                    )
                )
            ),
            '"/><feImage result="p1" xlink:href="data:image/svg+xml;base64,',
            Base64.encode(
                bytes(
                    string.concat(
                        "<svg width='290' height='500' viewBox='0 0 290 500' xmlns='http://www.w3.org/2000/svg'><circle cx='",
                        params.x1,
                        "' cy='",
                        params.y1,
                        "' r='120px' fill='#",
                        params.color1,
                        "'/></svg>"
                    )
                )
            ),
            '"/><feImage result="p2" xlink:href="data:image/svg+xml;base64,',
            Base64.encode(
                bytes(
                    string.concat(
                        "<svg width='290' height='500' viewBox='0 0 290 500' xmlns='http://www.w3.org/2000/svg'><circle cx='",
                        params.x2,
                        "' cy='",
                        params.y2,
                        "' r='120px' fill='#",
                        params.color2,
                        "'/></svg>"
                    )
                )
            ),
            '" />',
            '<feImage result="p3" xlink:href="data:image/svg+xml;base64,',
            Base64.encode(
                bytes(
                    string.concat(
                        "<svg width='290' height='500' viewBox='0 0 290 500' xmlns='http://www.w3.org/2000/svg'><circle cx='",
                        params.x3,
                        "' cy='",
                        params.y3,
                        "' r='100px' fill='#",
                        params.color3,
                        "'/></svg>"
                    )
                )
            ),
            '"/><feBlend mode="overlay" in="p0" in2="p1"/><feBlend mode="exclusion" in2="p2"/><feBlend mode="overlay" in2="p3" result="blendOut"/><feGaussianBlur ',
            'in="blendOut" stdDeviation="42"/></filter><clipPath id="corners"><rect width="290" height="500" rx="42" ry="42"/></clipPath>',
            '<path id="text-path-a" d="M40 12 H250 A28 28 0 0 1 278 40 V460 A28 28 0 0 1 250 488 H40 A28 28 0 0 1 12 460 V40 A28 28 0 0 1 40 12 z"/>',
            '<path id="minimap" d="M234 444C234 457.949 242.21 463 253 463"/>',
            '<filter id="top-region-blur"><feGaussianBlur in="SourceGraphic" stdDeviation="24"/></filter>',
            '<linearGradient id="grad-up" x1="1" x2="0" y1="1" y2="0"><stop offset="0.0" stop-color="#fff" stop-opacity="1"/>',
            '<stop offset=".9" stop-color="#fff" stop-opacity="0"/></linearGradient>',
            '<linearGradient id="grad-down" x1="0" x2="1" y1="0" y2="1"><stop offset="0.0" stop-color="#fff" stop-opacity="1"/><stop offset="0.9" stop-color="#fff" stop-opacity="0"/></linearGradient>',
            '<mask id="fade-up" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="url(#grad-up)"/></mask>',
            '<mask id="fade-down" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="url(#grad-down)"/></mask>',
            '<mask id="none" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="#fff"/></mask>',
            '<linearGradient id="grad-symbol"><stop offset="0.7" stop-color="#fff" stop-opacity="1"/><stop offset=".95" stop-color="#fff" stop-opacity="0"/></linearGradient>',
            '<mask id="fade-symbol" maskContentUnits="userSpaceOnUse"><rect width="290px" height="200px" fill="url(#grad-symbol)"/></mask></defs>',
            '<g clip-path="url(#corners)">',
            '<rect fill="',
            params.color0,
            '" x="0px" y="0px" width="290px" height="500px"/>',
            '<rect style="filter: url(#f1)" x="0px" y="0px" width="290px" height="500px"/>',
            '<g style="filter:url(#top-region-blur); transform:scale(1.5); transform-origin:center top;">',
            '<rect fill="none" x="0px" y="0px" width="290px" height="500px"/>',
            '<ellipse cx="50%" cy="0px" rx="180px" ry="120px" fill="#000" opacity="0.85"/></g>',
            '<rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="rgba(255,255,255,0.2)"/></g>'
        );
    }

    function generateSVGBorderText(
        string memory projectName,
        string memory challengeName,
        string memory solverAddr,
        string memory challengeAddr
    ) private pure returns (string memory svg) {
        svg = string.concat(
            '<text text-rendering="optimizeSpeed">',
            '<textPath startOffset="-100%" fill="#fff" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
            challengeName,
            unicode" • ",
            challengeAddr,
            '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite"/>',
            '</textPath> <textPath startOffset="0%" fill="#fff" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
            challengeName,
            unicode" • ",
            challengeAddr,
            '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite"/></textPath>',
            '<textPath startOffset="50%" fill="#fff" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
            projectName,
            unicode" • ",
            solverAddr,
            '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s"',
            ' repeatCount="indefinite"/></textPath><textPath startOffset="-50%" fill="#fff" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
            projectName,
            unicode" • ",
            solverAddr,
            '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite"/></textPath></text>'
        );
    }

    function generateSVGCardMantle(
        string memory solverAddr,
        string memory challengeAddr,
        uint32 rank,
        uint32 participants
    ) private pure returns (string memory svg) {
        svg = string.concat(
            '<g mask="url(#fade-symbol)"><rect fill="none" x="0px" y="0px" width="290px" height="200px"/><text y="70px" x="32px" fill="#fff" font-family="\'Courier New\', monospace" font-weight="200" font-size="36px">',
            solverAddr,
            '</text><text y="115px" x="32px" fill="#fff" font-family="\'Courier New\', monospace" font-weight="200" font-size="20px">',
            "Rank #",
            LibString.toString(rank),
            "/",
            LibString.toString(participants),
            "</text></g>"
        );
    }

    function generateRankBorder(uint32 rank) private pure returns (string memory svg) {
        if (rank == 1) {
            // Golden accent.
            svg =
                '<rect x="16" y="16" width="258" height="468" rx="26" ry="26" fill="rgba(0,0,0,0)" stroke="rgba(255,215,0,1.0)"/>';
        } else if (rank == 2) {
            // Silver accent.
            svg =
                '<rect x="16" y="16" width="258" height="468" rx="26" ry="26" fill="rgba(0,0,0,0)" stroke="rgba(255,255,255,1.0)"/>';
        } else if (rank == 3) {
            // Bronze accent.
            svg =
                '<rect x="16" y="16" width="258" height="468" rx="26" ry="26" fill="rgba(0,0,0,0)" stroke="rgba(205,127,50,1.0)"/>';
        } else {
            // Default (grey) accent. Assuming rank 0 is invalid, this case is for rank > 3.
            svg =
                '<rect x="16" y="16" width="258" height="468" rx="26" ry="26" fill="rgba(0,0,0,0)" stroke="rgba(255,255,255,0.2)"/>';
        }
    }

    function generateSvgCurve(int8 overR, string memory challengeSVG) private pure returns (string memory svg) {
        string memory fade = overR == 1 ? "#fade-up" : overR == -1 ? "#fade-down" : "#none";
        svg = string.concat(
            '<g mask="url(', fade, ')"', ' style="transform:translate(30px,130px)">', challengeSVG, "</g>"
        );
    }

    function generateSVGPositionDataAndLocationCurve(string memory tokenId, uint256 gasUsed, uint256 gasOpti)
        private
        pure
        returns (string memory svg)
    {
        string memory gasUsedStr = LibString.toString(gasUsed);
        string memory gasOptiStr = LibString.toString(gasOpti);
        uint256 str1length = bytes(tokenId).length + 4;
        uint256 str2length = bytes(gasUsedStr).length + 10;
        uint256 str3length = bytes(gasOptiStr).length + 10;
        svg = string.concat(
            '<g style="transform:translate(29px, 384px)">',
            '<rect width="',
            LibString.toString(uint256(7 * (str1length + 4))),
            'px" height="26px" rx="8px" ry="8px" fill="rgba(0,0,0,0.6)"/>',
            '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="#fff"><tspan fill="rgba(255,255,255,0.6)">ID: </tspan>',
            tokenId,
            "</text></g>",
            '<g style="transform:translate(29px, 414px)">',
            '<rect width="',
            LibString.toString(uint256(7 * (str2length + 4))),
            'px" height="26px" rx="8px" ry="8px" fill="rgba(0,0,0,0.6)"/>',
            '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="#fff"><tspan fill="rgba(255,255,255,0.6)">Gas used: </tspan>',
            gasUsedStr,
            "</text></g>",
            '<g style="transform:translate(29px, 444px)">',
            '<rect width="',
            LibString.toString(uint256(7 * (str3length + 4))),
            'px" height="26px" rx="8px" ry="8px" fill="rgba(0,0,0,0.6)"/>',
            '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="#fff"><tspan fill="rgba(255,255,255,0.6)">Gas opti: </tspan>',
            gasOptiStr,
            "%",
            "</text></g>"
        );
    }

    function generateSVGRareSparkle(uint32 rank) private pure returns (string memory svg) {
        if (rank == 1) {
            svg = string.concat(
                '<g style="transform:translate(226px, 392px)"><rect width="36px" height="36px" rx="8px" ry="8px" fill="none" stroke="rgba(255,255,255,0.2)"/>',
                '<g><path style="transform:translate(6px,6px)" d="M12 0L12.6522 9.56587L18 1.6077L13.7819 10.2181L22.3923 6L14.4341 ',
                "11.3478L24 12L14.4341 12.6522L22.3923 18L13.7819 13.7819L18 22.3923L12.6522 14.4341L12 24L11.3478 14.4341L6 22.39",
                '23L10.2181 13.7819L1.6077 18L9.56587 12.6522L0 12L9.56587 11.3478L1.6077 6L10.2181 10.2181L6 1.6077L11.3478 9.56587L12 0Z" fill="#fff"/>',
                '<animateTransform attributeName="transform" type="rotate" from="0 18 18" to="360 18 18" dur="10s" repeatCount="indefinite"/></g></g>'
            );
        }
    }

    function scale(uint256 n, uint256 inMn, uint256 inMx, uint256 outMn, uint256 outMx)
        internal
        pure
        returns (string memory)
    {
        return LibString.toString(((n - inMn) * (outMx - outMn)) / (inMx - inMn) + outMn);
    }

    function getCircleCoord(uint256 tokenAddress, uint256 offset, uint256 tokenId) internal pure returns (uint256) {
        return (sliceTokenHex(tokenAddress, offset) * tokenId) % 255;
    }

    function sliceTokenHex(uint256 token, uint256 offset) private pure returns (uint256) {
        return uint256(uint8(token >> offset));
    }
}

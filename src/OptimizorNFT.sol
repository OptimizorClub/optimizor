// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Challenge.sol";
import "./base64.sol";
import "./DataHelpers.sol";
import "./NFTSVG.sol";
import "./IPurityChecker.sol";
import "./IAttribute.sol";
import "./TokenDetails.sol";

import "solmate/auth/Owned.sol";
import "solmate/tokens/ERC721.sol";
import '@openzeppelin/contracts/utils/Strings.sol';

uint constant EPOCH = 256;

contract Optimizor is Owned, ERC721 {
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
        address holder;
        uint32 gas;
    }

    mapping (uint => Data) public challenges;
    mapping (uint => ExtraDetails) public extraDetails;

    IPurityChecker purity;
    IAttribute[] public extraAttrs;

    constructor(IPurityChecker pureh)
        ERC721("Test", "TTT")
        Owned(msg.sender) {
        purity = pureh;
    }

    /***********************************
       PUBLIC STATE MUTATING FUNCTIONS
    ************************************/

    function updatePurityChecker(IPurityChecker pureh) external onlyOwner {
        purity = pureh;
    }

    function addAttribute(IAttribute attr) external onlyOwner {
        extraAttrs.push(attr);
    }

    function addChallenge(uint id, IChallenge chlAddr) external onlyOwner {
        Data storage chl = challenges[id];
        if (address(chl.target) != address(0)) {
            revert ChallengeExists(id);
        }

        chl.target = chlAddr;

        emit ChallengeAdded(id, chlAddr);
    }

    function commit(bytes32 key) external {
        if (submissions[key].sender != address(0)) {
            revert CodeAlreadySubmitted();
        }
        submissions[key] = Submission({ sender: msg.sender, blockNumber: uint96(block.number) });
    }

    function challenge(
        uint256 id,
        address target,
        address recipient,
        uint salt
    ) external {
        Data storage chl = challenges[id];

        bytes32 codehash = target.codehash;
        bytes32 key = keccak256(abi.encode(msg.sender, codehash, salt));

        // Frontrunning cannot steal the submission, but can block
        // it for users at the expense of the frontrunner's gas.
        // We consider that a non-issue.
        if (submissions[key].blockNumber + EPOCH >= block.number) {
            revert TooEarlyToChallenge();
        }

        if (submissions[key].sender == address(0)) {
            revert CodeNotSubmitted();
        }


        if (address(chl.target) == address(0)) {
            revert ChallengeNotFound(id);
        }

        if (recipient == address(0)) {
            revert InvalidRecipient();
        }

        if (!purity.check(target)) {
            revert NotPure();
        }

        uint32 gas = uint32(chl.target.run(target, block.difficulty));

        uint winnerTokenId = packTokenId(id, chl.level);
        ExtraDetails storage prevDetails = extraDetails[winnerTokenId];

        if (prevDetails.gas != 0 && (prevDetails.gas <= gas)) {
            revert NotOptimizor();
        }

        unchecked {
            ++chl.level;
        }

        uint tokenId = packTokenId(id, chl.level);
        ERC721._mint(recipient, tokenId);
        extraDetails[tokenId] = ExtraDetails(target, recipient, gas);
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
            leaderDetails.holder,
            _ownerOf[leaderTokenId],
            leaderDetails.code,

            details.gas,
            level,
            details.holder,
            _ownerOf[tokenId],
            details.code
        );
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string.concat(
            'data:application/json;base64,',
            Base64.encode(
                bytes.concat(
                    '{',
                    '"name":"', "TestName", '", ',
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
            board[i - 1] = details.holder;
        }
    }

    function leaderboardString(uint tokenId) public view returns (string memory) {
        address[] memory leaders = leaderboard(tokenId);
        string memory leadersStr = "";
        uint lIdx = leaders.length;
        for (uint i = 0; i < leaders.length; ++i) {
            leadersStr = string.concat(
                "\\n",
                Strings.toString(lIdx),
                ". ",
                Strings.toHexString(uint(uint160(leaders[i])), 20),
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
}

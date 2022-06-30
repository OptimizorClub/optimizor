// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.15;

import "./BaseTest.sol";
import "../src/OptimizorNFT.sol";
import "../src/DataHelpers.sol";

contract OptimizorTest is BaseTest {
    function run() external returns (string memory) {
        setUp();
        testCheapExpensiveSqrt();
        uint tokenId = (SQRT_ID << 32) | 2;
        return opt.tokenURI(tokenId);
    }

    function testCheapSqrt() public {
        addSqrtChallenge();

        testChallenger(
            SQRT_ID,
            address(cheapSqrt),
            address(cheapSqrt).codehash
        );
    }

    function testExpensiveSqrt() public {
        addSqrtChallenge();

        testChallenger(
            SQRT_ID,
            address(expSqrt),
            address(expSqrt).codehash
        );
    }

    function testCheapExpensiveSqrt() public {
        addSqrtChallenge();

        testChallengers(
            SQRT_ID,
            address(expSqrt),
            address(expSqrt).codehash,
            address(cheapSqrt),
            address(cheapSqrt).codehash
        );
    }

    function testCheapSum() public {
        addSumChallenge();

        testChallenger(
            SUM_ID,
            address(cheapSum),
            address(cheapSum).codehash
        );
    }

    function testExpensiveSum() public {
        addSumChallenge();

        testChallenger(
            SUM_ID,
            address(expSum),
            address(expSum).codehash
        );
    }

    function testCheapExpensiveSum() public {
        addSumChallenge();

        testChallengers(
            SUM_ID,
            address(expSum),
            address(expSum).codehash,
            address(cheapSum),
            address(cheapSum).codehash
        );
    }

    function testChallengers(
        uint CHL_ID,
        address challenger_0,
        bytes32 chl_hash_0,
        address challenger_1,
        bytes32 chl_hash_1
    ) internal {
        address other = address(42);
        vm.prank(other);
        opt.commit(chl_hash_0);
        vm.stopPrank();

        opt.commit(chl_hash_1);

        advancePeriod();
        advancePeriod();

        (, uint32 preLevel) = opt.challenges(CHL_ID);

        vm.prank(other);
        opt.challenge(CHL_ID, chl_hash_0, challenger_0, other);
        vm.stopPrank();

        (, uint32 postLevel) = opt.challenges(CHL_ID);
        (address postOpt, ) = unpackExtraDetail(opt.extraDetails(packTokenId(CHL_ID, postLevel)));
        assertEq(postOpt, other);
        assertEq(postLevel, preLevel + 1);

        uint tokenId = (CHL_ID << 32) | postLevel;
        assertEq(opt.ownerOf(tokenId), other);

        address[] memory leaders = opt.leaderboard(tokenId);
        assertEq(leaders.length, 1);
        assertEq(leaders[0], other);

        opt.challenge(CHL_ID, chl_hash_1, challenger_1, address(this));
        (, uint32 postLevel2) = opt.challenges(CHL_ID);
        (address postOpt2, ) = unpackExtraDetail(opt.extraDetails(packTokenId(CHL_ID, postLevel2)));
        assertEq(postOpt2, address(this));
        assertEq(postLevel2, postLevel + 1);

        uint tokenId2 = (CHL_ID << 32) | postLevel2;
        assertEq(opt.ownerOf(tokenId2), address(this));

        vm.prank(other);
        vm.expectRevert(abi.encodeWithSignature("NotOptimizor()"));
        opt.challenge(CHL_ID, chl_hash_0, challenger_0, other);
        vm.stopPrank();

        address[] memory leaders2 = opt.leaderboard(tokenId2);
        assertEq(leaders2.length, 2);
        assertEq(leaders2[0], other);
        assertEq(leaders2[1], address(this));
    }

    // TODO make this function public too to fuzz it
    function testChallenger(uint CHL_ID, address challenger, bytes32 chl_hash) internal {
        opt.commit(chl_hash);
        advancePeriod();
        advancePeriod();

        (, uint32 preLevel) = opt.challenges(CHL_ID);
        opt.challenge(CHL_ID, chl_hash, challenger, address(this));
        (, uint32 postLevel) = opt.challenges(CHL_ID);
        (address postOpt, ) = unpackExtraDetail(opt.extraDetails(packTokenId(CHL_ID, postLevel)));
        assertEq(postOpt, address(this));
        assertEq(postLevel, preLevel + 1);

        uint tokenId = (CHL_ID << 32) | postLevel;
        assertEq(opt.ownerOf(tokenId), address(this));

        address[] memory leaders = opt.leaderboard(tokenId);
        assertEq(leaders.length, 1);
        assertEq(leaders[0], address(this));
    }
}

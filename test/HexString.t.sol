// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {HexString} from "../src/HexString.sol";

contract HexStringTest is Test {
    function testTooShort() public {
        vm.expectRevert(abi.encodeWithSignature("HexLengthInsufficient()"));
        HexString.toHexString(0xff00, 1);
    }

    function testTooShortNoPrefix() public {
        vm.expectRevert(abi.encodeWithSignature("HexLengthInsufficient()"));
        HexString.toHexStringNoPrefix(0xff00, 1);
    }

    function testHexString() public {
        assertEq(HexString.toHexString(0, 0), "0x");
        assertEq(HexString.toHexString(0, 1), "0x00");
        assertEq(HexString.toHexString(0, 2), "0x0000");
        assertEq(HexString.toHexString(1, 1), "0x01");
        assertEq(HexString.toHexString(0x7f07, 2), "0x7f07");
        assertEq(HexString.toHexString(0xbebebe, 3), "0xbebebe");
        assertEq(
            HexString.toHexString(0x00b4c79dab8f259c7aee6e5b2aa729821864227e84, 20),
            "0xb4c79dab8f259c7aee6e5b2aa729821864227e84"
        );
        assertEq(
            HexString.toHexString(0xff1122334455667788990000b4c79dab8f259c7aee6e5b2aa729821864227e84, 32),
            "0xff1122334455667788990000b4c79dab8f259c7aee6e5b2aa729821864227e84"
        );
    }

    function testHexStringNoPrefix() public {
        assertEq(HexString.toHexStringNoPrefix(0, 0), "");
        assertEq(HexString.toHexStringNoPrefix(0, 1), "00");
        assertEq(HexString.toHexStringNoPrefix(0, 2), "0000");
        assertEq(HexString.toHexStringNoPrefix(1, 1), "01");
        assertEq(HexString.toHexStringNoPrefix(0x7f07, 2), "7f07");
        assertEq(HexString.toHexStringNoPrefix(0xbebebe, 3), "bebebe");
        assertEq(
            HexString.toHexStringNoPrefix(0x00b4c79dab8f259c7aee6e5b2aa729821864227e84, 20),
            "b4c79dab8f259c7aee6e5b2aa729821864227e84"
        );
        assertEq(
            HexString.toHexStringNoPrefix(0xff1122334455667788990000b4c79dab8f259c7aee6e5b2aa729821864227e84, 32),
            "ff1122334455667788990000b4c79dab8f259c7aee6e5b2aa729821864227e84"
        );
    }
}

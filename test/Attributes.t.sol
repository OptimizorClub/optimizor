// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {BaseTest} from "./BaseTest.sol";
import {IAttribute, TokenDetails} from "../src/IAttribute.sol";

contract AttributeTest is BaseTest {
    Attributes attr = new Attributes();

    function testAttribute() public {
        opt.addAttribute(attr);
    }
}

contract Attributes is IAttribute {
    function attribute(TokenDetails memory /*details*/ )
        external
        pure
        returns (string memory attr, string memory value)
    {
        return ("someAttr", "yes");
    }
}

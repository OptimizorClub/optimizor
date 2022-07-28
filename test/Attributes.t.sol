// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.15;

import "./BaseTest.sol";
import "../src/OptimizorNFT.sol";
import "../src/DataHelpers.sol";
import "../src/IAttribute.sol";

contract AttributeTest is BaseTest {
}

contract Attributes is IAttribute {
    function attribute(TokenDetails memory details) external view returns (string memory attr, string memory value) {
        return ("", "");
    }
}

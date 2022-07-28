// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./TokenDetails.sol";

interface IAttribute {
    function attribute(TokenDetails memory details) external view returns (string memory attr, string memory value);
}

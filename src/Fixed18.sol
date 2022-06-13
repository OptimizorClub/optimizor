// SPADIX-License-Identifier: MIT
pragma solidity ^0.8.13;

type Fixed18 is uint256;
uint256 constant FIXED18BASE = 10**18;

function add(Fixed18 a, Fixed18 b) pure returns (Fixed18) {
    return Fixed18.wrap(Fixed18.unwrap(a) + Fixed18.unwrap(b));
}
function sub(Fixed18 a, Fixed18 b) pure returns (Fixed18) {
    return Fixed18.wrap(Fixed18.unwrap(a) - Fixed18.unwrap(b));
}
function mul(Fixed18 a, Fixed18 b) pure returns (Fixed18) {
    return Fixed18.wrap((Fixed18.unwrap(a) * Fixed18.unwrap(b)) / FIXED18BASE);
}
function div(Fixed18 a, Fixed18 b) pure returns (Fixed18) {
    return Fixed18.wrap((Fixed18.unwrap(a) * FIXED18BASE) / Fixed18.unwrap(b));
}
function distance(Fixed18 a, Fixed18 b) pure returns (Fixed18) {
    uint256 _a = Fixed18.unwrap(a);
    uint256 _b = Fixed18.unwrap(b);
    // TODO a branchless implementation
    unchecked {
        if (_a < _b) {
            return Fixed18.wrap(_b - _a);
        }
        else {
            return Fixed18.wrap(_a - _b);
        }
    }
}
function lt(Fixed18 a, Fixed18 b) pure returns (bool) {
    return Fixed18.unwrap(a) < Fixed18.unwrap(b);
}

using {add, sub, mul, div, distance, lt} for Fixed18 global;

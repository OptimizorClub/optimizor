// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import {ISqrt, INPUT_SIZE, SqrtChallenge, Fixed18} from "src/challenges/SqrtChallenge.sol";

/// Returns the midpoint avoiding phantom overflow
function mid(uint256 a, uint256 b) pure returns (uint256) {
    unchecked {
        return (a & b) + (a ^ b) / 2;
    }
}

abstract contract DefaultSqrt is ISqrt {
    function sqrt_one(Fixed18 input) internal pure returns (Fixed18 output) {
        uint256 l = 0;
        uint256 uInput = Fixed18.unwrap(input);
        uint256 r = uInput - 1;
        while (l < r) {
            uint256 m = mid(l, r);
            uint256 mPlus1 = m + 1;
            if ((m * m <= uInput) && (mPlus1 * mPlus1 > uInput)) {
                return Fixed18.wrap(m * 10 ** 9);
            }
            if (m * m < uInput) {
                l = m;
            } else {
                r = m;
            }
        }
        revert("wrong algorithm");
    }
}

contract CheapSqrt is DefaultSqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata inputs) external pure returns (Fixed18[INPUT_SIZE] memory outputs) {
        for (uint256 i = 0; i < inputs.length; ++i) {
            outputs[i] = sqrt_one(inputs[i]);
        }
    }
}

contract ExpensiveSqrt is DefaultSqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata inputs) external pure returns (Fixed18[INPUT_SIZE] memory outputs) {
        for (uint256 i = 0; i < inputs.length; ++i) {
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
        }
    }
}

contract ExpensiveSqrt2 is DefaultSqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata inputs) external pure returns (Fixed18[INPUT_SIZE] memory outputs) {
        for (uint256 i = 0; i < inputs.length; ++i) {
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
        }
    }
}

contract ExpensiveSqrt3 is DefaultSqrt {
    function sqrt(Fixed18[INPUT_SIZE] calldata inputs) external pure returns (Fixed18[INPUT_SIZE] memory outputs) {
        for (uint256 i = 0; i < inputs.length; ++i) {
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
            outputs[i] = sqrt_one(inputs[i]);
        }
    }
}

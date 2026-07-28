// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Fibonacci {
    function fib(uint256 n) public pure returns (uint256) {
        if (n == 0) return 0;
        uint256 a = 0;
        uint256 b = 1;
        for (uint256 i = 1; i < n; i++) {
            uint256 c = a + b;
            a = b;
            b = c;
        }
        return b;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Fibonacci} from "./Fibonacci.sol";

contract FibonnaciTest is Test {
    Fibonacci private fibonacci;

    string private constant RUN_BIN = "./src/differential-test/rust_ffi/target/release/rust_ffi";

    function setUp() public {
        fibonacci = new Fibonacci();
    }

    function testFuzz_DifferentialFibonacci(uint8 rawN) public {
        uint256 n = bound(rawN, 0, 90);

        // call solidity
        uint256 solResult = fibonacci.fib(n);

        // call rust FFI
        string[] memory inputs = new string[](2);
        inputs[0] = RUN_BIN;
        inputs[1] = vm.toString(n);

        bytes memory ffiResult = vm.ffi(inputs);

        // decode ABI result on uint256
        uint256 rustResult = abi.decode(ffiResult, (uint256));

        assertEq(solResult, rustResult, "Output solidity and rust not suitable");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { HelloWolrd } from "./HelloWorld.sol";

contract HelloWolrdTest is Test {
    HelloWolrd helloWolrd;

    function setUp() public {
        helloWolrd = new HelloWolrd();
    }

    function test_Greeting() external {
        assertEq(helloWolrd.greeting(), "Hello World");
    }
}

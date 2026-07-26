// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console2 } from "forge-std/Test.sol";
import { SimpleAddition } from "./SimpleAddition.sol";
import { UsingInterface } from "./UsingInterface.sol";

contract UsingInterface_test is Test {
    SimpleAddition simpleAddition;
    UsingInterface usingInterface;

    function setUp() public {
        simpleAddition = new SimpleAddition();
        usingInterface = new UsingInterface(address(simpleAddition));
    }

    function test_A() external {
        usingInterface.setA(20);
        assertEq(simpleAddition.a(), 20);
    }

    function test_B() external {
        usingInterface.setB(50);
        assertEq(simpleAddition.b(), 50);
    }

    function test_returnSumOfStateVariablesWithoutChange() external {
        assertEq(simpleAddition.returnSumOfStateVariables(), 60);
    }

    function test_returnSumOfStateVariablesWithChange() external {
        usingInterface.setA(40);
        usingInterface.setB(40);
        assertEq(simpleAddition.returnSumOfStateVariables(), 80);
    }

    function test_returnSumOfLocalVariables() external {
        assertEq(simpleAddition.returnSumOfLocalVariables(10, 20), 30);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console2 } from "forge-std/Test.sol";

contract SetterGetter {
    uint256 public number;

    function setNumber(
        uint256 _number
    ) public {
        number = _number;
    }

    function getNumber() public view returns (uint256 _number) {
        _number = number;
    }
}

contract SetterGetterTest is Test {
    SetterGetter setterGetter;

    function setUp() public {
        setterGetter = new SetterGetter();
    }

    function test_SetNumber() public {
        // setterGetter.setNumber(10);
        // assertEq(setterGetter.number(), 10);
        uint256 numberBefore = setterGetter.number();
        setterGetter.setNumber(10);
        uint256 numberAfter = setterGetter.number();

        assertEq(numberBefore, 0);
        assertEq(numberAfter, 10);
    }

    // avoid these kinds of tests.
    // function testFail_SetNumber() public {
    //     setterGetter.setNumber(type(uint256).max + 1);
    // }

    function test_getNumber_Simple() public {
        setterGetter.setNumber(10);
        assertEq(setterGetter.getNumber(), 10);
    }

    function test_getNumber_Robust() public {
        setterGetter.setNumber(322e26);
        assertEq(setterGetter.getNumber(), 322e26);
        assertEq(setterGetter.getNumber(), setterGetter.number());

        setterGetter.setNumber(0);
        assertEq(setterGetter.getNumber(), 0);
        assertEq(setterGetter.getNumber(), setterGetter.number());
    }
}

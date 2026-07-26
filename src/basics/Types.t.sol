// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console2 } from "forge-std/Test.sol";
import { ValueType_vs_ReferenceType } from "./Types.sol";

contract Type_Test is Test {
    ValueType_vs_ReferenceType types;

    function setUp() public {
        types = new ValueType_vs_ReferenceType();
    }

    function test_modifyValueType() public {
        types.modifyValueType(20);

        assertEq(types.valueVar1(), 10);
    }

    function test_modifyReferenceType() public {
        console2.log("The original value of referanceVar1[0] is", types.referenceVar1(0));
        console2.log("The original value of referanceVar1[1] is", types.referenceVar1(1));

        types.modifyReferenceType(0, 20);
        types.modifyReferenceType(1, 30);

        assertEq(types.referenceVar1(0), 20);
        assertEq(types.referenceVar1(1), 30);
    }
}

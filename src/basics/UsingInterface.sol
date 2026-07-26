// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Interface_SimpleAddition } from "./Interface_SimpleAddition.sol";

contract UsingInterface {
    Interface_SimpleAddition public IsimpleAddition;

    constructor(
        address __simpleAdditionAddress
    ) {
        IsimpleAddition = Interface_SimpleAddition(__simpleAdditionAddress);
    }

    function setA(
        uint256 _a
    ) external {
        IsimpleAddition.setA(_a);
    }

    function setB(
        uint256 _b
    ) external {
        IsimpleAddition.setB(_b);
    }

    function returnSumOfStateVariables() external view returns (uint256) {
        return IsimpleAddition.returnSumOfStateVariables();
    }

    function returnSumOfLocalVariables(
        uint256 _a,
        uint256 _b
    ) external view returns (uint256) {
        return IsimpleAddition.returnSumOfLocalVariables(_a, _b);
    }
}

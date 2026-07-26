// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ValueType_vs_ReferenceType {
    uint256 public valueVar1 = 10;

    uint256[] public referenceVar1 = [1, 2, 3];

    function modifyValueType(
        uint256 _newValue
    ) public {
        uint256 valueVar2 = valueVar1;

        valueVar2 = _newValue;
    }

    function modifyReferenceType(
        uint256 _index,
        uint256 _newValue
    ) public {
        uint256[] storage referenceVar2 = referenceVar1;

        referenceVar2[_index] = _newValue;
    }
}

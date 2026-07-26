// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Vault {
    mapping(address => uint256) public balanceOf;
    uint256 public totalDeposits;

    function deposit() external payable {
        require(msg.value > 0, "zero deposit");
        balanceOf[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balanceOf[msg.sender] > 0, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        totalDeposits -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
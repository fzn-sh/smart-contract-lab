// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Vault} from "./Vault.sol";
import {Test} from "forge-std/Test.sol";

contract VaultHandler is Test {
    Vault public vault;
    address[] public actors;
    mapping(address => bool) public isActor;

    constructor(Vault _vault) {
        vault = _vault;
    }

    function deposit(uint256 amount) public payable {
        if (msg.sender == address(vault) || msg.sender == address(this) || msg.sender == address(0)) {
            return;
        }
        
        amount = bound(amount, 1, 100);
        deal(msg.sender, amount);

        vm.startPrank(msg.sender);
        vault.deposit{value: amount}();
        vm.stopPrank();

        if (!isActor[msg.sender]) {
            isActor[msg.sender] = true;
            actors.push(msg.sender);
        }    
    }

    function withdraw(uint256 actorIndex, uint256 amount) public {
        if (actors.length == 0) return;

        actorIndex = bound(actorIndex, 0, actors.length - 1);
        address actor = actors[actorIndex];

        uint256 userBalance = vault.balanceOf(actor);
        if (userBalance == 0) return;

        amount =  bound(amount, 1, userBalance);

        vm.startPrank(actor);
        vault.withdraw(amount);
        vm.stopPrank();
    }

}
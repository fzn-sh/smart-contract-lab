// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vault} from "./Vault.sol";
import {VaultHandler} from "./VaultHandler.sol";

contract VaultTest is Test {
    Vault public vault;
    VaultHandler public handler;

    function setUp() public {
        vault = new Vault();
        handler = new VaultHandler(vault);

        targetContract(address(handler));
    }

    function invariant_vaultSolvency() public {
        assertEq(
            address(vault).balance,
            vault.totalDeposits(),
            "INVARIANT_SOLVENCY_VIOLATED: Balance does not match total deposits"       
        );
    }
}
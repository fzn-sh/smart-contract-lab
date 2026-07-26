// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { DiscountVault } from "./DiscountVault.sol";

contract DiscountVaultTest is Test {
    DiscountVault vault;

    function setUp() public {
        vault = new DiscountVault();
    }

    function test_UnitCalculateDiscount() public view {
        uint256 finalPrice = vault.calculateDiscountedPrice(100, 20);
        assertEq(finalPrice, 80);
    }

    function test_FuzzCalculateDiscount(
        uint256 price,
        uint256 discountPercent
    ) public view {
        discountPercent = bound(discountPercent, 0, 100);

        uint256 finalPrice = vault.calculateDiscountedPrice(price, discountPercent);

        assertLe(finalPrice, price);
    }
}

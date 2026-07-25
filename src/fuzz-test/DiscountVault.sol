// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract DiscountVault {
    function calculateDiscountedPrice(
        uint256 price,
        uint256 discountPercent
    ) public pure returns (uint256) {
        require(discountPercent <= 100, "Invalid discount");

        // require(price <= type(uint256).max / 100, "Price too high");

        uint256 discountAmount = (price * discountPercent) / 100;
        return price - discountAmount;
    }
}

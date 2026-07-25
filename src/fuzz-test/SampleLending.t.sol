// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console2 } from "forge-std/Test.sol";
import { SampleLending, MockToken } from "./SampleLending.sol";

contract SampleLendingTest is Test {
    SampleLending protocol;
    MockToken token;
    address feeReceiver = address(0x123);

    function setUp() public {
        token = new MockToken();
        protocol = new SampleLending(feeReceiver);
    }

    function test_Repayment() public {
        uint256 principal = 100 ether;
        uint256 rate = 1000; // 10% APR
        uint256 time = 30 days;

        (uint256 interest, uint256 fees) = protocol.calculateInterest(principal, rate, time);
        assertGt(fees, 0, "Fees should be greater than zero");

        vm.startPrank(address(this));
        token.mint(address(this), fees);
        token.approve(address(protocol), type(uint256).max);

        protocol.repay(address(token), principal, rate, time);
        vm.stopPrank();
    }

    function test_FuzzRepayment(
        uint256 principal,
        uint256 rate,
        uint256 time
    ) public {
        principal = bound(principal, 1, 1e36);
        rate = bound(rate, 10, 100_000);
        time = bound(time, 1 seconds, 365 days);

        (uint256 interest, uint256 fees) = protocol.calculateInterest(principal, rate, time);

        vm.startPrank(address(this));

        if (fees > 0) {
            token.mint(address(this), fees);
            token.approve(address(protocol), type(uint256).max);
        }

        protocol.repay(address(token), principal, rate, time);
        vm.stopPrank();
    }
}

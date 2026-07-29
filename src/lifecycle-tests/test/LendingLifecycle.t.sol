// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {MockERC20} from "../src/MockERC20.sol";
import {LendingWithLiquidation} from "../src/LendingWithLiquidation.sol";

contract LendingLifecycleTest is Test {
    MockERC20 token;
    LendingWithLiquidation lending;

    address user = address(0x1);
    address liquidator = address (0x2);
    uint256 constant INITIAL_BALANCE = 10000 ether;

    function setUp() public {
        token = new MockERC20();
        lending = new LendingWithLiquidation(address(token));

        token.mint(user, INITIAL_BALANCE);
        token.mint(liquidator, INITIAL_BALANCE);
        token.mint(address(lending), INITIAL_BALANCE);
    }

    function test_LendingLifecycle() public {
        vm.startPrank(user);
        token.approve(address(lending), 1000 ether);
        lending.deposit(1000 ether);
        vm.stopPrank();

        assertEq(lending.deposits(user), 1000 ether);
        assertEq(lending.totalDeposits(), 1000 ether);

        vm.prank(user);
        lending.borrow(700 ether);
        
        assertEq(lending.borrows(user), 700 ether);
        assertEq(lending.totalBorrows(), 700 ether);

        vm.expectRevert("Exceeds borrow limit");
        vm.startPrank(user);
        lending.borrow(150 ether);
        vm.stopPrank();

        vm.startPrank(user);
        token.approve(address(lending), 200 ether);
        lending.repay(200 ether);
        vm.stopPrank();

        assertEq(lending.borrows(user), 500 ether);
        assertEq(lending.totalBorrows(), 500 ether);

        vm.prank(user);
        lending.withdraw(100 ether);

        assertEq(lending.deposits(user), 900 ether);
        assertEq(lending.totalDeposits(), 900  ether);

        vm.prank(user);
        lending.borrow(200 ether);

        assertEq(lending.borrows(user), 700 ether);
        lending.setPrice(0.8 ether); // 20% price drop

        uint256 liquidatorBalanceBefore = token.balanceOf(liquidator);
        vm.startPrank(liquidator);
        token.approve(address(lending), 300 ether);
        lending.liquidate(user, 300 ether);
        vm.stopPrank();
        uint256 liquidatorBalanceAfter = token.balanceOf(liquidator);

        assertLt(lending.borrows(user), 700 ether);
        assertLt(lending.deposits(user), 900 ether);
        assertGt(liquidatorBalanceAfter, liquidatorBalanceBefore);
        
        uint256 remainingDebt = lending.borrows(user);
        vm.startPrank(user);
        token.approve(address(lending), remainingDebt);
        lending.repay(remainingDebt);
        vm.stopPrank();

        assertEq(lending.borrows(user), 0);

        uint256 remainingDeposit = lending.deposits(user);
        vm.prank(user);
        lending.withdraw(remainingDeposit);

        assertEq(lending.deposits(user), 0);
        assertEq(lending.totalBorrows(), 0);
        assertEq(lending.totalDeposits(), 0);
        assertLt(token.balanceOf(user), INITIAL_BALANCE);
        assertGt(token.balanceOf(liquidator), INITIAL_BALANCE);
    }
}
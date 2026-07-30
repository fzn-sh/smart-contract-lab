// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {MockERC20} from "../src/MockERC20.sol";
import {Vesting} from "../src/Vesting.sol";

contract VestingTest is Test {
    MockERC20 token;
    Vesting vesting;

    address admin = address(this);
    address beneficiary = address(0xABC);

    uint256 constant TOTAL_AMOUNT = 1000 ether;
    uint256 constant VESTING_DURATION = 365 days;

    function setUp() public {
        token = new MockERC20();
        vesting = new Vesting();
        token.mint(admin, TOTAL_AMOUNT);
    }

    function test_VestingLifecycle() public {
        // verify initial state
        assertEq(uint256(vesting.state()), uint256(Vesting.VestingState.Uninitialized));
        assertEq(vesting.owner(),admin);
        assertEq(address(vesting.token()), address(0));

        // initialize the vesting contract
        vesting.initialize(beneficiary, VESTING_DURATION);

        assertEq(vesting.beneficiary(), beneficiary);
        assertEq(vesting.vestingDuration(), VESTING_DURATION);
        assertEq(uint256(vesting.state()), uint256(Vesting.VestingState.Initialized));

        // fund the vesting contract
        token.approve(address(vesting), TOTAL_AMOUNT);
        vesting.fund(token, TOTAL_AMOUNT);

        assertEq(token.balanceOf(address(vesting)), TOTAL_AMOUNT);
        assertEq(uint256(vesting.state()), uint256(Vesting.VestingState.Funded));

        // start vesting period
        vesting.startVesting();

        assertEq(uint256(vesting.state()), uint256(Vesting.VestingState.Vesting));
        assertEq(vesting.vestingStart(), block.timestamp);

        // test partial vesting at 25% duration
        vm.warp(block.timestamp + VESTING_DURATION / 4);

        uint256 expectedRevert = TOTAL_AMOUNT / 4; // 25% should be vasted
        assertApproxEqRel(vesting.vestedAmount(), expectedRevert, 0.01e18);
        
        // make partial claim
        uint256 preClaimBalance = token.balanceOf(beneficiary);

        vm.prank(beneficiary);
        vesting.claim();

        uint256 claimedAmount = token.balanceOf(beneficiary) - preClaimBalance;
        assertApproxEqRel(claimedAmount, expectedRevert, 0.01e18);

        // test full vesting completion
        vm.warp(block.timestamp + VESTING_DURATION);
        assertEq(vesting.vestedAmount(), TOTAL_AMOUNT);

        // final claim
        vm.prank(beneficiary);
        vesting.claim();
        
        assertEq(uint256(vesting.state()), uint256(Vesting.VestingState.Completed));
        assertEq(token.balanceOf(beneficiary), TOTAL_AMOUNT);
        assertEq(token.balanceOf(address(vesting)), 0);

        // verify post-completion state
        vm.expectRevert(
            abi.encodeWithSelector(
                Vesting.InvalidState.selector,
                Vesting.VestingState.Completed,
                Vesting.VestingState.Vesting
            )
        );
        vm.prank(beneficiary);
        vesting.claim();
    }
}
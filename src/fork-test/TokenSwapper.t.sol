// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console2 } from "forge-std/Test.sol";
import { IERC20, ISwapRouter, TokenSwapper } from "./TokenSwapper.sol";

contract TokenSwapperTest is Test {
    TokenSwapper swapper;

    address constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address user = address(0x123);

    function setUp() public {
        vm.createSelectFork("https://mainnet.infura.io/v3/018e3e4bc15540f4b221a5054d7403c8", 19_000_000);

        swapper = new TokenSwapper(UNISWAP_V3_ROUTER);
    }

    // MOCK-TEST
    function test_SwapDaiForWETH_Mock() public {
        uint256 amountIn = 1000e18;
        uint256 expectedOut = 0.3 ether;

        // Mock transferFrom DAI
        vm.mockCall(DAI, abi.encodeWithSelector(IERC20.transferFrom.selector), abi.encode(true));

        // Mock executed Swap Uniswap V3 Router
        vm.mockCall(
            UNISWAP_V3_ROUTER, abi.encodeWithSelector(ISwapRouter.exactInputSingle.selector), abi.encode(expectedOut)
        );

        vm.prank(user);
        uint256 amountOut = swapper.swapDAIForWETH(amountIn, expectedOut);

        assertEq(amountOut, expectedOut);
    }

    // FORK-TEST
    function test_SwapDaiForWETH_Fork() public {
        uint256 amountIn = 1000e18;

        // give balance to wallet user
        deal(DAI, user, amountIn);

        vm.startPrank(user);
        // User allowance approve to contract tokenSwapper
        IERC20(DAI).approve(address(swapper), amountIn);

        // executed swap on liquidity pool UNISWAP V3 MAINNET
        uint256 amountOut = swapper.swapDAIForWETH(amountIn, 0);

        // log swap
        console2.log("Total WETH(wei):", amountOut);
        uint256 integerPart = amountOut / 1e18;
        uint256 decimalPart = (amountOut % 1e18) / 1e16;
        string memory formattedWETH = string.concat(vm.toString(integerPart), ".", vm.toString(decimalPart));
        console2.log("Total WETh(Ether):", formattedWETH);

        vm.stopPrank();

        assertGt(amountOut, 0);
        assertEq(IERC20(WETH).balanceOf(user), amountOut);
    }
}

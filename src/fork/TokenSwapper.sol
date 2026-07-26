// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function approve(
        address spender,
        uint256 amount
    ) external returns (bool);
    function balanceOf(
        address account
    ) external view returns (uint256);
}

interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external returns (uint256 amountOut);
}

contract TokenSwapper {
    ISwapRouter public immutable swapRouter;

    // MAINNET $DAI & $WETH
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor(
        address _swapRouter
    ) {
        swapRouter = ISwapRouter(_swapRouter);
    }

    function swapDAIForWETH(
        uint256 amountIn,
        uint256 minAmountOut
    ) external returns (uint256 amountOut) {
        IERC20(DAI).transferFrom(msg.sender, address(this), amountIn);

        // EXAMPLE: BUG FORGET TO GIVE ALLOWANCE
        IERC20(DAI).approve(address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: DAI,
            tokenOut: WETH,
            fee: 500, // 0.05%
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: minAmountOut,
            sqrtPriceLimitX96: 0
        });

        amountOut = swapRouter.exactInputSingle(params);
    }
}

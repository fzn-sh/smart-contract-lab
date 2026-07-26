// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console2, stdError } from "forge-std/Test.sol";

interface IERC4626 {
    function convertToShares(
        uint256 assets
    ) external view returns (uint256);
}

contract MainnetController {
    address public immutable SPARK_PROXY;

    uint256 public constant RATE_LIMIT = 5_000_000e18;

    struct ExchangeRateLimit {
        uint256 maxShare;
        uint256 maxAssets;
    }

    mapping(address => ExchangeRateLimit) public maxExchangeRates;
    mapping(address => uint256) public usdsBalances;

    modifier onlySparkProxy() {
        require(msg.sender == SPARK_PROXY, "MC/not-spark-proxy");
        _;
    }

    constructor(
        address sparkProxy
    ) {
        SPARK_PROXY = sparkProxy;
    }

    function mintUSDS(
        uint256 amount
    ) external {
        usdsBalances[msg.sender] += amount;
    }

    function setMaxExchangeRate(
        address asset,
        uint256 maxShares,
        uint256 maxAssets
    ) external onlySparkProxy {
        maxExchangeRates[asset] = ExchangeRateLimit(maxShares, maxAssets);
    }

    function deposit(
        address asset,
        uint256 amount
    ) external {
        if (amount > RATE_LIMIT) {
            revert("RateLimits/rate-limit-exceeded");
        }

        ExchangeRateLimit memory limit = maxExchangeRates[asset];

        if (limit.maxShare > 0 && limit.maxAssets > 0) {
            uint256 currentShares = IERC4626(asset).convertToShares(amount);

            if (amount * limit.maxShare > currentShares * limit.maxAssets) {
                revert("MC/exchange-rate-too-high");
            }
        }
    }
}

/// TESTING CONTRACT ///

contract MockERC4626 is IERC4626 {
    function convertToShares(
        uint256 assets
    ) external pure override returns (uint256) {
        return assets;
    }
}

contract MainnetControllerTest is Test {
    MainnetController mainnetController;
    MockERC4626 suds;

    address relayer = address(0x1);
    address sparkProxy = address(0x2);

    function setUp() public {
        mainnetController = new MainnetController(sparkProxy);
        suds = new MockERC4626();
    }

    function test_depositERC4626_rateLimitBoundary() external {
        vm.startPrank(relayer);

        mainnetController.mintUSDS(5_000_000e18);

        vm.expectRevert("RateLimits/rate-limit-exceeded");
        mainnetController.deposit(address(suds), 5_000_000e18 + 1);

        mainnetController.deposit(address(suds), 5_000_000e18);

        vm.stopPrank();
    }

    function test_depositERC4626_exchangeRateBoundary() external {
        vm.prank(relayer);
        mainnetController.mintUSDS(5_000_000e18);

        vm.startPrank(sparkProxy);
        mainnetController.setMaxExchangeRate(address(suds), suds.convertToShares(5_000_000e18), 5_000_000e18 - 1);
        vm.stopPrank();

        vm.prank(relayer);
        vm.expectRevert("MC/exchange-rate-too-high");
        mainnetController.deposit(address(suds), 5_000_000e18);

        vm.startPrank(sparkProxy);
        mainnetController.setMaxExchangeRate(address(suds), suds.convertToShares(5_000_000e18), 5_000_000e18);
        vm.stopPrank();

        vm.prank(relayer);
        mainnetController.deposit(address(suds), 5_000_000e18);
    }
}

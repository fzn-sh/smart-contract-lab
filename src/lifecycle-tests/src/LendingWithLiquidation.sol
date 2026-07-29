// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MockERC20} from "./MockERC20.sol";

abstract contract AdvancedLending {
    MockERC20 public immutable token;
    uint256 public constant COLLATERAL_FACTOR = 800; // 80%

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public totalDeposits;
    uint256 public totalBorrows;

    constructor(address _token) {
        token = MockERC20(_token);
    }

    function deposit(uint256 amount) external {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        deposits[msg.sender] += amount;
        totalDeposits += amount;
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient Deposit");
        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }

    function borrow(uint256 amount) external virtual;
    function repay(uint256 amount) external {
        require(borrows[msg.sender] >= amount, "Repay exceeds debt");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        borrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }
}

contract LendingWithLiquidation is AdvancedLending {
    uint256 public constant LIQUIDATION_THRESHOLD = 850; // 85%
    uint256 public constant LIQUIDATION_BONUS = 50; // 5%
    uint256 public price = 1e18; // default $1.00

    error NoDebtToLiquidate();
    error PositionNotLiquidatable();
    error InsufficientCollateral();
    error TransferFailed();

    constructor(address _token) AdvancedLending(_token) {}

    function setPrice(uint256 _price) external {
        price = _price;
    }

    function borrow(uint256 amount) external override {
        uint256 maxBorrow = (deposits[msg.sender] * price * COLLATERAL_FACTOR) / 1000 / 1e18;
        require(borrows[msg.sender] + amount <= maxBorrow, "Exceeds borrow limit");

        borrows[msg.sender] += amount;
        totalBorrows += amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }

    function liquidate(address borrower, uint256 amount) external {
        uint256 borrowerDebt = borrows[borrower];
        if (borrowerDebt == 0) revert NoDebtToLiquidate();

        // Total value of user collateral based on current price (USD)
        uint256 collateralValueUSD = (deposits[borrower] * price) / 1e18;

        // Maximum debt threshold before position is liquidated (85% of collateral value)
        uint256 maxAllowedDebt = (collateralValueUSD * LIQUIDATION_THRESHOLD) / 1000;

        if (borrowerDebt <= maxAllowedDebt) revert PositionNotLiquidatable();

        // Limit on the amount of debt that can be liquidated in one transaction
        uint256 maxLiquidation = (borrowerDebt * LIQUIDATION_THRESHOLD) / 1000;
        uint256 actualLiquidation = amount > maxLiquidation ? maxLiquidation : amount;

        // Calculate the amount of collateral that the liquidator is entitled to receive (payable / Token price) + 5 bonuses%
        uint256 collateralToLiquidate = (actualLiquidation * 1e18) / price;
        uint256 liquidationBonus = (collateralToLiquidate * LIQUIDATION_BONUS) / 1000;
        uint256 totalCollateralToLiquidator = collateralToLiquidate + liquidationBonus;

        if (deposits[borrower] < totalCollateralToLiquidator) revert InsufficientCollateral();

        // Transfer of debt tokens from the liquidator to the protocol
        if (!token.transferFrom(msg.sender, address(this), actualLiquidation)) revert TransferFailed();

        // Update state internal
        borrows[borrower] -= actualLiquidation;
        totalBorrows -= actualLiquidation;
        deposits[borrower] -= totalCollateralToLiquidator;
        totalDeposits -= totalCollateralToLiquidator;

        // Transfer of funds + bonuses to the liquidator
        if (!token.transfer(msg.sender, totalCollateralToLiquidator)) revert TransferFailed();
    }
}
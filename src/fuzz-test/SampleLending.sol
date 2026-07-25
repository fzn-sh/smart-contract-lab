// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract SampleLending {
    uint256 public constant FEE_PERCENTAGE = 1000; // 10%
    address public feeReceiver;

    constructor(address _feeReceiver) {
        feeReceiver = _feeReceiver;
    }

    function calculateInterest(uint256 principal, uint256 rate, uint256 time) public pure returns (uint256 interest, uint256 fees) {
        interest = (rate * principal * time) / 10000 / 365 days;
        fees = (FEE_PERCENTAGE * interest) / 10000;
        interest -= fees;
    }

    function repay(address token, uint256 principal, uint256 rate, uint256 time) external {
        (uint256 interest, uint256 fees) = calculateInterest(principal, rate, time);

        // if (fees > 0) {
            IERC20(token).transferFrom(msg.sender, feeReceiver, fees);
        // }
    }
}

contract MockToken {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowance;

    function mint(address account, uint256 amount) external {
        _balances[account] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(amount > 0, "Cannot transfer zero tokens");
        require(_balances[sender] >= amount, "Insufficient balance");
        require(_allowance[sender][msg.sender] >= amount, "Insufficient allowance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowance[sender][msg.sender] -= amount;

        return true;
    }

}
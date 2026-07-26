// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console2 } from "forge-std/Test.sol";

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function balanceOf(
        address account
    ) external view returns (uint256);
}

contract Vault {
    IERC20 public immutable token;

    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(
        address _tokenAddress
    ) {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IERC20(_tokenAddress);
    }

    function deposit(
        uint256 _amount
    ) external {
        require(_amount > 0, "amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer Failed!");

        balances[msg.sender] += _amount;

        emit Deposit(msg.sender, _amount);
    }

    function withdraw(
        uint256 _amount
    ) external {
        require(_amount > 0, "amount must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        require(token.transfer(msg.sender, _amount), "Transfer Failed!");

        emit Withdraw(msg.sender, _amount);
    }
}

contract VaultTest is Test {
    Vault vault;

    address tokenA = makeAddr("TokenA");

    function setUp() public {
        vault = new Vault(tokenA);
    }

    function test_deposit() external {
        vm.mockCall(address(tokenA), abi.encodeWithSelector(IERC20.transferFrom.selector), abi.encode(true));
        vault.deposit(10);
        assert(vault.balances(address(this)) == 10);
    }
}

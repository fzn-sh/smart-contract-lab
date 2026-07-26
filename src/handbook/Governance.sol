// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console2, stdError } from "forge-std/Test.sol";

interface IVault {
    function setRewardRate(
        uint256 _rewardRate
    ) external;
}

contract Vault {
    address public governance;
    uint256 public rewardRate;

    modifier onlyGovernance() {
        require(msg.sender == governance, "Only the governance can perform this action");
        _;
    }

    constructor(
        address _governance
    ) {
        governance = _governance;
    }

    function setRewardRate(
        uint256 _rewardRate
    ) public onlyGovernance {
        rewardRate = _rewardRate;
    }
}

contract Governance {
    address public owner;
    mapping(address vault => uint256 rewardRate) public rewardRate;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function setRewardRate(
        address _vaultAddress,
        uint256 _rewardRate
    ) public onlyOwner {
        rewardRate[_vaultAddress] = _rewardRate;

        IVault(_vaultAddress).setRewardRate(_rewardRate);
    }
}

contract GovernanceIntegrationTest is Test {
    Governance governance;
    Vault vault;

    function setUp() public {
        governance = new Governance();
        vault = new Vault(address(governance));
    }

    function test_GovernanceUpdatesRewardRate() external {
        uint256 newRewardRate = 100;

        governance.setRewardRate(address(vault), newRewardRate);

        assertEq(vault.rewardRate(), newRewardRate, "Vault's rewardRate should be updated to 100");
    }
}

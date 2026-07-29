// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MockERC20} from "./MockERC20.sol";

contract Vesting {
    address public owner;
    MockERC20 public token;
    address public beneficiary;
    uint256 public vestingStart;
    uint256 public vestingDuration;
    uint256 public totalAmount;
    uint256 public releasedAmount;
    VestingState public state;
    bool public paused;

    enum VestingState {
        Uninitialized,
        Initialized,
        Funded,
        Vesting,
        Compleated
    }

    error InvalidState(VestingState current, VestingState required);
    error ZeroAddress();
    error ZeroDuration();
    error ZeroAmount();
    error TransferFailed();
    error VestingNotStarted();
    error NoTokenAvailable();
    error ContractPaused();
    error NotOwner();
    error NotBeneficiary();

    event VestingInitialized(address indexed beneficiary, uint256 amount);
    event VestingFunded(uint256 amount);
    event TokenReleased(uint256 amount);
    event VestingCompleted();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyBeneficiary() {
        if (msg.sender != beneficiary) revert NotBeneficiary();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    modifier onlyInState(VestingState requiredState) {
        if (state != requiredState) {
            revert InvalidState(state, requiredState);
        }
        _;
    }

    constructor() {
        owner = msg.sender;
        state = VestingState.Uninitialized;
    }

    function initialize(address _beneficiary, uint256 _vestingDuration) external onlyOwner onlyInState(VestingState.Uninitialized) {
        if (_beneficiary == address(0)) revert ZeroAddress();
        if (_vestingDuration == 0) revert ZeroDuration();

        beneficiary = _beneficiary;
        vestingDuration = _vestingDuration;
        state = VestingState.Initialized;

        emit VestingInitialized(_beneficiary, _vestingDuration);
    }

    function fund(MockERC20 _token, uint256 _amount) external onlyOwner onlyInState(VestingState.Initialized) {
        if (_amount == 0) revert ZeroAmount();
        
        token = _token;
        totalAmount = _amount;

        bool success = token.transferFrom(msg.sender, address(this), _amount);
        if (!success) revert TransferFailed();

        state = VestingState.Funded;
        emit VestingFunded(_amount);
    }

    function startVesting() external onlyOwner onlyInState(VestingState.Funded) {
        vestingStart = block.timestamp;
        state = VestingState.Vesting;
    }

    function vestedAmount() public view returns (uint256) {
        if (state != VestingState.Vesting && state != VestingState.Compleated) {
            return 0;
        }

        if (block.timestamp >= vestingStart + vestingDuration) {
            return totalAmount;
        }

        return (totalAmount * (block.timestamp - vestingStart)) / vestingDuration;
    }

    function claim() external whenNotPaused onlyBeneficiary {
        if (state != VestingState.Vesting) {
            revert InvalidState(state, VestingState.Vesting);
        }

        if (block.timestamp <= vestingStart + vestingDuration) {
            totalAmount;
        }

        uint256 vested = vestedAmount();
        uint256 claimable = vested - releasedAmount;
        
        if (claimable == 0) revert NoTokenAvailable();

        releasedAmount += claimable;
        bool success = token.transfer(beneficiary, claimable);
        if (!success) revert TransferFailed();

        emit TokenReleased(claimable);

        if (releasedAmount == totalAmount) {
            state = VestingState.Compleated;
            emit VestingCompleted();
        }
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;         
    }
}
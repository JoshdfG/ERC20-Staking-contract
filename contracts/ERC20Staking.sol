// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IERC20.sol";

contract StakingRewards {
    IToken public immutable stakingToken;
    IToken public immutable rewardsToken;

    address public stakeOwner;

    uint256 public duration;
    uint256 public endAt;
    uint256 public lastUpdateTime;
    uint256 public rewardRate;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 public totalStaked;
    mapping(address => uint256) public userStakeBalance;

    constructor(address _stakingToken, address _rewardToken) {
        stakeOwner = msg.sender;
        stakingToken = IToken(_stakingToken);
        rewardsToken = IToken(_rewardToken);
    }

    modifier onlyStakeOwner() {
        require(msg.sender == stakeOwner, "Not authorized");
        _;
    }

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }

        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return min(endAt, block.timestamp);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate *
                (lastTimeRewardApplicable() - lastUpdateTime) *
                1e18) /
            totalStaked;
    }

    function stake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "_amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        userStakeBalance[msg.sender] += _amount;
        totalStaked += _amount;
    }

    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "_amount = 0");
        userStakeBalance[msg.sender] -= _amount;
        totalStaked -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function earned(address _address) public view returns (uint256) {
        return
            (userStakeBalance[_address] *
                (rewardPerToken() - userRewardPerTokenPaid[_address])) /
            1e18 +
            rewards[_address];
    }

    function getReward() external updateReward(msg.sender) {
        uint256 _reward = rewards[msg.sender];
        if (_reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, _reward);
        }
    }

    function setRewardsDuration(uint256 _duration) external onlyStakeOwner {
        require(endAt < block.timestamp, "Reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(
        uint256 _amount
    ) external onlyStakeOwner updateReward(address(0)) {
        if (block.timestamp >= endAt) {
            rewardRate = _amount / duration;
        } else {
            uint256 remainingRewards = (endAt - block.timestamp) * rewardRate;
            rewardRate = (_amount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "Reward rate = 0");
        require(
            rewardRate * duration <= rewardsToken.balance(address(this)),
            "Reward amount > balance"
        );

        endAt = block.timestamp + duration;
        lastUpdateTime = block.timestamp;
    }

    function min(uint256 _x, uint256 _y) private pure returns (uint256) {
        return _x <= _y ? _x : _y;
    }
}

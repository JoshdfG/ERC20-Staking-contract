// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IToken {
    function total() external view returns (uint);

    function balance(address acc) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

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

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();

        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
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

    function stake(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), amount);
        userStakeBalance[msg.sender] += amount;
        totalStaked += amount;
    }

    function withdraw(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Amount = 0");
        userStakeBalance[msg.sender] -= amount;
        totalStaked -= amount;
        stakingToken.transfer(msg.sender, amount);
    }

    function earned(address account) public view returns (uint256) {
        return
            (userStakeBalance[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) /
            1e18 +
            rewards[account];
    }

    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    function setRewardsDuration(uint256 _duration) external onlyStakeOwner {
        require(endAt < block.timestamp, "Reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(
        uint256 amount
    ) external onlyStakeOwner updateReward(address(0)) {
        if (block.timestamp >= endAt) {
            rewardRate = amount / duration;
        } else {
            uint256 remainingRewards = (endAt - block.timestamp) * rewardRate;
            rewardRate = (amount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "Reward rate = 0");
        require(
            rewardRate * duration <= rewardsToken.balance(address(this)),
            "Reward amount > balance"
        );

        endAt = block.timestamp + duration;
        lastUpdateTime = block.timestamp;
    }

    function min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
}

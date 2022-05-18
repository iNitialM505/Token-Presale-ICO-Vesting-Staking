// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Staking{

    struct stakingConfig{
        uint timestamp;
        uint staked;
        uint totalRewards;
        uint rewards;
        uint claimed;
    }

    mapping(address => stakingConfig) private userStakingData;

    IERC20 private token;

    ///@notice Total tokens alloted to stakinf contract for stake rewards
    uint private stakeTokenPool;

    ///@notice Maximum tokens an address can stake
    uint private maxTokensStake;

    ///@notice Staking rewards rate
    uint private stakeRewardRate;

    ///@notice Time period after which rewards will be calculated for the user
    uint private constant stakingRewardCycle = 1 days;

    constructor(IERC20 _token){
        token = _token;
    }

    function storeTokens(address user, uint _stakeAmount) private{
        token.approve(address(this), _stakeAmount);
        token.transferFrom(user, address(this), _stakeAmount);
    }

    function setUser(address user,uint amount) private {
        userStakingData[user].timestamp=block.timestamp;
        userStakingData[user].staked += amount;
    }


    function stake(uint _stakeAmount) public {
        require(_stakeAmount!=0,'Cannot stake 0');
        require(token.balanceOf(msg.sender)>=_stakeAmount,'You do not have enought tokens to stake');
        uint stakedAmount = userStakingData[msg.sender].staked;
        require(stakedAmount==maxTokensStake,'Maximum limit for staking has reached for you already');
        if(userStakingData[msg.sender].timestamp==0){
        
            storeTokens(msg.sender, _stakeAmount);
            setUser(msg.sender, _stakeAmount);

        }
        else if(stakedAmount+_stakeAmount<maxTokensStake){

            updateRewards(msg.sender);
            storeTokens(msg.sender, _stakeAmount);
            setUser(msg.sender, _stakeAmount);

        }
        else{

            updateRewards(msg.sender);
            storeTokens(msg.sender, _stakeAmount);
            setUser(msg.sender, maxTokensStake-stakedAmount);

        }
    }

    // function calculateRewards(address staker) public {
    //     uint rewards = (stakeRewardRate*userStakingData[staker].staked*(block.timestamp - userStakingData[staker].timestamp)/1 ether) - userStakingData[staker].claimed;
    //     userStakingData[staker].rewards = rewards;
    //    // return rewards;
    // }
    function rewardFunction(address staker) private view returns(uint rewardAmount){
        return rewardAmount = (stakeRewardRate*userStakingData[staker].staked*(block.timestamp - userStakingData[staker].timestamp)/1 ether);
    }

    function updateRewards(address staker) private {
        uint rewardAmount = rewardFunction(staker);
        userStakingData[staker].totalRewards += rewardAmount;
    }

    function getRewardsToClaim(address user) public view returns(uint){
       uint amount = rewardFunction(user);
       uint rewardsToClaim = amount + userStakingData[user].totalRewards - userStakingData[user].claimed;
       return rewardsToClaim;

    }

    function claimRewards() public{
       uint rewardsToClaim = getRewardsToClaim(msg.sender);
       token.transfer(msg.sender, rewardsToClaim);
    }

}
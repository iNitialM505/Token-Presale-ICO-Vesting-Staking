// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Vesting{

    struct vest{
        uint vestPeriod;
        uint cliff;
        uint tokens;
        uint claimed;
    }

    uint private immutable cliffStart;
    IERC20 private immutable token;

    mapping(address => vest) private vestingInfoUser;

    uint private vestingPeriod = 365 days;
    uint private releaseCycle = vestingPeriod/12;

    //Vesting tokens are alloted to private investors, team members, pre-sale investors
    //linear vesting of 12 months

    constructor(address[] memory _users, uint[] memory _vestPeriod, uint[] memory _cliff, uint[] memory _tokens, IERC20 _token){
        uint count = _users.length;
        for(uint i=0;i<count;i+=1){
            vestingInfoUser[_users[i]]=vest(_vestPeriod[i],_cliff[i],_tokens[i],0);
        }

        cliffStart = block.timestamp;
        token = _token;

    }

    function _checkCliff(address user) internal view returns(bool){
        if(block.timestamp >= vestingInfoUser[user].cliff+cliffStart){
            return true;
        }else{return false;}
    }

   function claimTokens() public {
       require(_checkCliff(msg.sender),'The cliff period is not over yet');
       vest memory userInfo = vestingInfoUser[msg.sender];
       uint multiplier = (block.timestamp-(userInfo.cliff + cliffStart))/releaseCycle;
       uint vestAmount = (multiplier*userInfo.tokens)/12 - userInfo.claimed;

       token.transfer(msg.sender,vestAmount);
   }

   //Just for fun function
   function balanceOfContract() public view returns(uint){
       return token.balanceOf(address(this));
   }

    

}
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import '@openzeppelin/contracts/access/Ownable.sol';

contract PreSale is Ownable{

    //only whitelisted address could buy from this sale
    //whitelisted users will be depositing ether via this contract
    //in return they will be not be getting anything since the token has not been listed yet
    //there will be a fixed amount of tokens that will be assigned for this
    //the rate will be in ether for the token
    //token can only be bought against ether since we are using ethereum blockchain
    //there would be the minimum cap for tokens to be bought at once = 100 tokens 
    //rate = 0.001 ether
    //no maximum cap

    mapping (address => bool) private whitelisted;

    uint private whitelisted_addresses;

    mapping (address => uint) private balance;

    uint private maxCap = 10000000*1e18;

    uint private rate = 1*1e12;

    uint private totalSold;

    uint private startTime;

    uint private endTime;

    modifier isWhitelisted (address _addr){
        require(whitelisted[_addr],'your address is not whitelisted');
        _;
    } 

    constructor(uint _start, uint _end){
        startTime=_start;
        endTime=_end;
    }



    function updateWhitelist(address[] memory whitelistAddress) public onlyOwner{
        for(uint i=whitelisted_addresses;i<whitelistAddress.length;i++){
            whitelisted[whitelistAddress[i]] = true;
        }
        whitelisted_addresses += whitelistAddress.length;

    }


    function buyTokens() public isWhitelisted(msg.sender) payable{

        require(block.timestamp>startTime,'Sale has not started yet');
        require(block.timestamp<endTime,'Sale has expired');

        require(msg.value >= 1e17 ether, 'Minimum amount to buy is 100 tokens');
        
        uint amount = calculate(msg.value);

        require(tokensLeft()>=amount,'Not enough tokens left to buy, check tokensLeft()');
        balance[msg.sender]= amount;
        totalSold+=amount;
    }

    function calculate(uint value) private view returns(uint){
        return value*rate;
    }


    function minimumCap() public pure returns(uint){
        return 100*1e18;
    }


    function rateOfToken() public view returns(uint){
        return rate;
    }


    function tokensLeft() public view returns(uint){
        return maxCap-totalSold;
    }


    function getTotalAddress() public view onlyOwner returns(uint){
        return whitelisted_addresses;        
    }

    
}
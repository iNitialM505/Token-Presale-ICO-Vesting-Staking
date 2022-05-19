//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract ICO is Ownable{
    //start time, end time, open to all, fixed supply, available on fixed rate, soft cap, hard cap
    //no minimum buying cap,


    ///@notice For 1 wei you will be getting 2*1e12/decimalOfToken = 2*1e12/1e18 = c tokens
    //uint private rate1=4*1e12;

    ///@notice For 1 wei you will be getting 2*1e12/decimalOfToken = 2*1e12/1e18 = 0.000002 tokens
    //uint private rate2=2*1e12;

    ///@notice For 1 wei you will be getting 2*1e12/decimalOfToken = 2*1e12/1e18 = 0.000001 tokens
    //uint private rate3=1*1e12;

    ///@notice Total 20 Million tokens are to be sold at ICO in 3 stages which  are divided into 
    ///        4 mil, 6 mil, 10 mil supply respectively


    uint private icoSaleNumber;

    IERC20 private token;

    address payable private immutable wallet;

    struct ICOdata{
        uint rate;
        uint supply;
        uint end;
        uint sold;
    }

    ICOdata[] private ICOdatas;


    constructor (IERC20 _token, address payable _wallet, uint rate1, uint rate2, 
                    uint rate3, uint supply1, uint supply2, uint supply3) 
    {

        token = IERC20(_token);
        wallet = _wallet;

        ICOdatas[0]=ICOdata(rate1, supply1,0,0);
        ICOdatas.push(ICOdata(rate2, supply2,0,0));
        ICOdatas.push(ICOdata(rate3, supply3,0,0));

    }

    function startSale(uint _icoSaleNumber, uint endTime) public onlyOwner{
        
        if(_icoSaleNumber==1 && endTime>block.timestamp + 1 days){
            ICOdatas[_icoSaleNumber].end = endTime;
            icoSaleNumber = _icoSaleNumber;
        }
        else if(_icoSaleNumber==2 && endTime>block.timestamp+1 days){
            require(ICOdatas[_icoSaleNumber-2].end<block.timestamp, 'Previous sale has not ended yet');
            ICOdatas[_icoSaleNumber].end = endTime;
            icoSaleNumber = _icoSaleNumber;
        }
        else if(_icoSaleNumber==3 && endTime>block.timestamp+1 days){
            require(ICOdatas[_icoSaleNumber-2].end<block.timestamp, 'Previous sale has not ended yet');
            ICOdatas[_icoSaleNumber].end = endTime;
            icoSaleNumber = _icoSaleNumber;
        }
    }

    function allowance() public view onlyOwner returns(uint){
        return token.allowance(msg.sender, address(this));
    }

    //make sure you approve tokens to this contract address
    function buy() public payable{
        require(icoSaleNumber>0 && _saleIsActive(),'Sale not active');
        uint amount = _calculate(msg.value);
        require(ICOdatas[icoSaleNumber].sold+amount<=ICOdatas[icoSaleNumber].supply,'Not enough tokens, try buying lesser amount');
        token.transferFrom(address(this), msg.sender, amount);
        ICOdatas[icoSaleNumber].sold+=amount;
    }

    function _saleIsActive() private view returns(bool){
        if(block.timestamp>=ICOdatas[icoSaleNumber-1].end && 
            tokensLeft()==0)
        {
            return false;
        }
        else{return true;}
    }


    function _calculate(uint value) private view returns(uint){
        return value*ICOdatas[icoSaleNumber].rate;
    }

    function tokensLeft() public view returns(uint){
        return ICOdatas[icoSaleNumber].supply-ICOdatas[icoSaleNumber].sold;
    }


    function weiRaised(uint saleNumber) public view returns(uint) {
        require(saleNumber>0 && saleNumber<4,'This sale does not exists');
        return ICOdatas[saleNumber-1].sold/ICOdatas[saleNumber-1].rate;
    }

    function claimWei() public onlyOwner {
        wallet.transfer(address(this).balance);
    }

    // function isSuccess() public view onlyOwner returns(bool){
    //     require(!_saleIsActive(),'Sale need to end first');
    //     if(weiRaisedAmount>=softCapWei){
    //         return true;
    //     }else{return false;}
    // }


}

// 1 wei = 0.000002 tokens
// 1 ether = 1e12 tokens
// number of tokens in 'y' amount of wei => y*0.000002 tokens in real life => y*0.000002*1e18 tokens where 1e18 is the decimal of token
// example: 100 wei will get me => 0.0002 tokens => 100*2*1e18/1e6 = 2*1e14 tokens in solidity
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract CarrotToken is ERC20, ERC20Burnable {

    ///@dev Supply is 100 million
    ///@dev decimal is 18

    constructor() ERC20('CARROT','CRRT'){
        _mint(msg.sender, 100**6 * 1e18);
    }

    function decimals() public pure override returns(uint8){
        return 18;
    }

}
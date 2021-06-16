// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;
import  'openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

contract Corso is ERC20{
    constructor(uint256 initialSupply) public ERC20("CHOWCHOW" , "CHOW"){
        _mint(msg.sender ,initialSupply*10**18);
        
    }
    
}
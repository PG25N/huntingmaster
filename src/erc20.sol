// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract erc20{
    string public name = "geonCoin";
    string public symbol = "G";
    uint8 decimal=18;
    uint256 totalSupply;
    
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
   
    function transfer(address _to, uint256 _value) public returns (bool){
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        allowance[msg.sender][_spender] = _value;
        return true;
    }

function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        allowance[_from][msg.sender] -= _value;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        return true;
    }

function mint(uint amount) public{
    balanceOf[msg.sender] += amount;
    totalSupply += amount;
}

function burn(uint amount) public{
    balanceOf[msg.sender] -= amount;
    totalSupply -= amount;
}

}
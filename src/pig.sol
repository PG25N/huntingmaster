// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract pig{
    mapping(address => uint) public balanceOf;

    function deposit() payable public{
     balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public{
    require(amount <= balanceOf[msg.sender], "errer");

    balanceOf[msg.sender] -= amount;

     (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
    //잔액확인은 balanceOf
}
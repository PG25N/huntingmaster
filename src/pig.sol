// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract pig {
    mapping(address => uint256) public balanceOf;

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(amount <= balanceOf[msg.sender], "errer");

        balanceOf[msg.sender] -= amount;

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
    //잔액확인은 balanceOf
}

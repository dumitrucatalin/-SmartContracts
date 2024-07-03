// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract ETHVaultContract {
    uint256 public totalBalanceReceived;

    mapping(address => uint256) public userBalances;

    function deposit() public payable {
        totalBalanceReceived += msg.value;
        userBalances[msg.sender] += msg.value;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address user) public view returns (uint256) {
        return userBalances[user];
    }

    function withdrawAll() public {
        uint256 amount = userBalances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        userBalances[msg.sender] = 0; // Zero out the balance first to prevent reentrancy
        totalBalanceReceived -= amount;

        address payable to = payable(msg.sender);
        to.transfer(amount);
    }

    function withdrawToAddress(address payable to) public {
        uint256 amount = userBalances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        userBalances[msg.sender] = 0; // Zero out the balance first to prevent reentrancy
        totalBalanceReceived -= amount;

        to.transfer(amount);
    }
}

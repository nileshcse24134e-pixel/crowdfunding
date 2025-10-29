// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CrowdfundProject
 * @dev A simple crowdfunding contract that allows users to contribute funds
 * and the owner to withdraw once the goal is reached.
 */
contract CrowdfundProject {
    address public owner;
    uint public goal;
    uint public deadline;
    uint public totalFunds;
    mapping(address => uint) public contributions;

    event Funded(address indexed contributor, uint amount);
    event Withdrawn(address indexed owner, uint amount);
    event Refunded(address indexed contributor, uint amount);

    constructor(uint _goal, uint _durationInDays) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
    }

    // Allows users to fund the project before the deadline
    function fund() external payable {
        require(block.timestamp < deadline, "Funding period ended");
        require(msg.value > 0, "Must send some ETH");
        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;
        emit Funded(msg.sender, msg.value);
    }

    // Allows the owner to withdraw funds if the goal is met
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(block.timestamp >= deadline, "Deadline not reached");
        require(totalFunds >= goal, "Goal not reached");

        uint amount = address(this).balance;
        payable(owner).transfer(amount);
        emit Withdrawn(owner, amount);
    }

    // Refund contributors if goal not met
    function refund() external {
        require(block.timestamp >= deadline, "Funding not ended yet");
        require(totalFunds < goal, "Goal was reached");
        uint contributed = contributions[msg.sender];
        require(contributed > 0, "No contribution found");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributed);
        emit Refunded(msg.sender, contributed);
    }
}


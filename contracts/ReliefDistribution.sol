// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReliefDistribution {
    address public admin;
    mapping(address => uint256) public balances;
    mapping(address => bool) public registeredCardholders;

    event FundAdded(address indexed from, uint256 amount);
    event ReliefDistributed(address indexed to, uint256 amount);
    event BalanceRemoved(address indexed from, uint256 amount);
    event FundsTransferred(address indexed from, address indexed to, uint256 amount);

    constructor() {
        admin = 0xE6118dee2b5AD0Ef223c9d18e7205C61276Cb2b5;
        registeredCardholders[admin] = true;
        registeredCardholders[0x67B78C81E588AE632A6785c8C905542dC1995ae1] = true;
        registeredCardholders[0x02596FB70Fe2f0f28b0219561EF5d13cfA72B4E0] = true;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyRegisteredCardholder() {
        require(registeredCardholders[msg.sender], "Only registered cardholders can call this function");
        _;
    }

    function registerCardholder(address cardholder) public onlyAdmin {
        registeredCardholders[cardholder] = true;
    }

    function addFunds() public payable onlyAdmin {
        require(msg.value > 0, "Amount should be greater than 0");
        balances[msg.sender] += msg.value;
        emit FundAdded(msg.sender, msg.value);
    }

    function distributeRelief(address payable cardholder, uint256 amount) public onlyAdmin {
        require(registeredCardholders[cardholder], "Cardholder is not registered");
        require(balances[admin] >= amount, "Insufficient funds");

        balances[admin] -= amount;
        cardholder.transfer(amount);

        emit ReliefDistributed(cardholder, amount);
    }

    function transferFunds(address payable to, uint256 amount) public onlyRegisteredCardholder {
        require(registeredCardholders[to], "Recipient is not a registered cardholder");
        require(balances[msg.sender] >= amount, "Insufficient funds");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        to.transfer(amount);

        emit FundsTransferred(msg.sender, to, amount);
    }

    function removeBalance(address payable to, uint256 amount) public onlyAdmin {
        require(balances[admin] >= amount, "Insufficient funds");

        balances[admin] -= amount;
        to.transfer(amount);

        emit BalanceRemoved(admin, amount);
    }
}

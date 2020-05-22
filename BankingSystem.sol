pragma solidity ^0.4.24;
contract BankingSystem{
    struct Account {
        address owner;
        uint amount;
    }
    address public serviceHolder;
    uint public numAccount;
    uint public bankingFee;
    mapping (string => Account) accounts;
    mapping (uint => string) accountList;
    
    constructor() public {
        serviceHolder = msg.sender;
        bankingFee = 0;
        numAccount = 0;
    }
    
    modifier onlyFromOwner(string _name) {
        require(accounts[_name].owner == msg.sender);
        _;
    }
    
    modifier onlyServiceHolder() {
        require(serviceHolder == msg.sender);
        _;
    }
    
    ///Registeration costs 0.1 eth
    ///initial registeration fee is 1eth
    function register(string _name) public payable returns(bool) {
        uint deposit = msg.value;
        if(accounts[_name].owner == 0 && deposit >= 1000000000) {
            //add to accounts
            Account storage acc = accounts[_name];
            acc.owner = msg.sender;
            bankingFee += 100000000;
            acc.amount += (deposit-bankingFee);
            
            //add to account list
            accountList[numAccount] = _name;
            numAccount++;
            return true;
        }
        return false;
    }
    
    function checkAccount(string _name) public view onlyFromOwner(_name) returns(uint) {
        return accounts[_name].amount;
    }
    
    function withdraw(string _name, uint _amount) public onlyFromOwner(_name) {
        require(accounts[_name].amount >= _amount);
        accounts[_name].amount -= _amount;
        if(!msg.sender.send(_amount)) {
            accounts[_name].amount += _amount;
            revert();
        }
    }
    
    function collect() public onlyServiceHolder() {
        uint income = bankingFee;
        bankingFee = 0;
        if(!msg.sender.send(income)) {
            bankingFee += income;
            revert();
        }
    }
    
    function distributeRevenue() public payable onlyServiceHolder() {
        uint quotient = msg.value;
        uint total = 0;
        for(uint i = 0; i < numAccount; i++) {
            total += accounts[accountList[i]].amount;
        }
        for(uint j = 0; j < numAccount; j++) {
            uint portion = accounts[accountList[j]].amount;
            uint pie = quotient * portion / total;
            if(total > 0) {
                if(total > pie) {
                    accounts[accountList[j]].amount += pie;
                    total -= pie;
                } else {
                    accounts[accountList[j]].amount += total;
                    total = 0;
                }
            }
        }
    }
}
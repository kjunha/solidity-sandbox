pragma solidity ^0.4.24;
/*
    practice for getter and setter of struct.
*/
contract NameRegistry {
    struct Contract {
        address owner;
        address addr;
        string description;
    }
    uint public numContracts;
    mapping (bytes32 => Contract) public contracts;
    constructor() public {
        numContracts = 0;
    }
    
    modifier onlyOwner(bytes32 _name) {
        require(contracts[_name].owner == msg.sender);
        _;
    }
    
    function register(bytes32 _name) public returns (bool) {
        if(contracts[_name].owner == 0) {
            Contract storage con = contracts[_name];
            con.owner = msg.sender;
            numContracts++;
            return true;
        } else {
            return false;
        }
    }
    
    function unregister(bytes32 _name) public returns (bool) {
        if(contracts[_name].owner == msg.sender) {
            contracts[_name].owner = 0;
            numContracts--;
            return true;
        } else {
            return false;
        }
    }
    
    function changeOwner(bytes32 _name, address _newOwner) public onlyOwner(_name) {
        contracts[_name].owner = _newOwner;
    }
    
    function getOwner(bytes32 _name) constant public returns (address) {
        return contracts[_name].owner;
    }
    
    function setAddr(bytes32 _name, address _addr) public onlyOwner(_name) {
        contracts[_name].addr = _addr;
    }
    
    function getAddr(bytes32 _name) constant public returns(address) {
        return contracts[_name].addr;
    }
    
    function setDescription(bytes32 _name, string _description) public onlyOwner(_name) {
        contracts[_name].description = _description;
    }
    
    function getDescription(bytes32 _name) constant public returns(string) {
        return contracts[_name].description;
    }
}


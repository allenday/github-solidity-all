pragma solidity ^0.4.8;

contract Register {
    // Mapping of the users registered names  
    mapping (address => string) public names;
    // Mapping of the registered address
    mapping (uint => address) public members;
    // Owner of the contract
    address public owner;
    // Count of registered users
    uint public memberCount = 0;

    // Modifier
    // Check if the address is registered
    modifier isRegistered { require(keccak256(names[msg.sender]) == keccak256("")); _;}
 
    // Constructor
    function Register() public {
        owner = msg.sender;
    }

    // Register a user in the ledger
    function add(string _name) public returns (bool success) {
        names[msg.sender] = _name;
        members[memberCount] = msg.sender;
        memberCount++; 
        return true;
    }
}
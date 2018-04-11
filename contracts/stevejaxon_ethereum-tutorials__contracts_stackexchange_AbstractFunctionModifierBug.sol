pragma solidity ^0.4.18;

// https://ethereum.stackexchange.com/questions/30565/why-specification-of-modifier-without-returns-is-incorrect
contract Parent1 {
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getBalance(address _address) public onlyOwner returns (uint256);
    // Does compile
    function setBalance(address _address, uint256 _amount) onlyOwner public;
}

contract Parent2 {
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getBalance(address _address) public onlyOwner returns (uint256);
    // Does not compile
    // function setBalance(address _address, uint256 _amount) public onlyOwner;
}
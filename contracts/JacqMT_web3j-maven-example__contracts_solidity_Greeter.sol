pragma solidity ^0.4.17;
contract mortal {
    address owner;
    function mortal() public { owner = msg.sender; }
    function kill() public { if (msg.sender == owner) selfdestruct(owner); }
}
contract greeter is mortal {
    string greeting;
    // constructor
    function greeter(string _greeting) public {
        greeting = _greeting;
    }
    // getter
    function greet() public constant returns (string) {
        return greeting;
    }
    //setter
    function newGreeting(string _greeting) public {
        greeting = _greeting;
    }
}
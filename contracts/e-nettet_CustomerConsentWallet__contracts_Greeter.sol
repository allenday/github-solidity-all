pragma solidity ^0.4.6;

contract Mortal {
    address owner;

    function Mortal() { owner = msg.sender; }
    function kill() { if (msg.sender == owner) selfdestruct(owner); }
}

contract Greeter is Mortal {
    string greeting;

    event SendGreeting(address to, address owner, string greeting);

    function greet(address to, string greeting) returns (string) {
      SendGreeting(to, msg.sender, greeting);
      return greeting;
    }
}

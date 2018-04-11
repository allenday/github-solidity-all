pragma solidity ^0.4.0;

contract Examples {
    string Monkey;
    uint public MagicNumber;

    event Changed(address a, string message);

    function Examples() {
        Monkey = "Monkey";
        MagicNumber = 42;
    }

    function getMonkey() constant returns (string) {
        return Monkey;
    }

    function setMonkey(string MonkeyName) {
        Monkey = MonkeyName;
        Changed(msg.sender, "The monkey's name changed");
    }

    function getMagicNumber() constant returns (uint) {
        return MagicNumber;
    }

    function setMagicNumber(uint mn) {
        MagicNumber = mn;
        Changed(msg.sender, "The MagicNumber Updated");
    }
}
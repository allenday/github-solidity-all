pragma solidity ^0.4.0;

contract Examples {
    string Monkey = "Monkey";
    uint MagicNumber = 42;
    
    function getMonkey() constant returns (string) {
        return Monkey;
    }
    
    function setMonkey(string MonkeyName) {
        Monkey = MonkeyName;
    }
    
    function getMagicNumber() constant returns (uint) {
        return MagicNumber;
    }
    
    function setMagicNumber(uint mn) {
        MagicNumber = mn;
    }
}
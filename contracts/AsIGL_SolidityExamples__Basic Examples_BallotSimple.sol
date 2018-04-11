pragma solidity ^0.4.0;


contract CallerContract{
    CalledContract toBeCalled = CalledContract(0x692a70d2e424a56d2c6c27aa97d1a86395877b3a);

    function getNumber() constant returns (uint256){
        return toBeCalled.getNumbers();
    }

    function getWords() constant returns(bytes32){
        return toBeCalled.getWords();
    }


}

contract CalledContract{
    uint256 number = 42;
    bytes32 words = "Hello World";

    function getNumbers() constant returns (uint256){
        return number;
    }

    function setNumbers(uint _number) {
        number = _number;
    }

    function getWords() constant returns (bytes32) {
        return words;
    }

}
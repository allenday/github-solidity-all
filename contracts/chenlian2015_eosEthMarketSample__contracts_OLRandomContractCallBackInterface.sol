pragma solidity ^0.4.15;


contract OLRandomContractCallBackInterface {
    /*
    @param randomValue,a random number send back to random request
    */
    function callBackForRequestRandom(bytes32 randomValue)public returns(uint);

    function getCurrentVersion() public returns (uint version){
        return 1;
    }
}
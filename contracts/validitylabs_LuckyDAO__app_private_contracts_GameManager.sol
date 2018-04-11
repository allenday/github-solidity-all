pragma solidity ^0.4.8;


import "./LuckyDAO.sol";


contract GameManager {

    function createGame(uint _endTimeStamp, address _redeemer) returns (address){
        //create a new PROD game at least 10 minutes in the future
        if(_endTimeStamp < block.timestamp + 600){
            return 0x0;
        } else {
            return new LuckyDAO(_endTimeStamp, _redeemer, LuckyDAO.Environment.PROD);
        }

    }
}
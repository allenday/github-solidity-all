pragma solidity ^0.4.4;

import "./Cmc.sol";

contract CmcEnabled {
    address cmcAddress;
    bytes32 seniorContractName;

    function init(address _cmcAddress, bytes32 _seniorContractName) returns (bool result){

        if(_cmcAddress == 0x0){
            return false;
        }

        if(cmcAddress != 0x0 && cmcAddress != msg.sender){
            return false;
        }

        cmcAddress = _cmcAddress;
        seniorContractName = _seniorContractName;
        return true;
    }

    function remove(){
        if(cmcAddress == msg.sender){
            selfdestruct(cmcAddress);
        }
    }

    function getCmcAddress() constant returns (address _cmcAddress){
        _cmcAddress = cmcAddress;
    }

    function getSeniorContract() constant returns (bytes32 _seniorContractName){
        _seniorContractName = seniorContractName;
    }

    function getContract(bytes32 name) constant returns (address _address){
        _address = Cmc(cmcAddress).getContract(name);
    }

    //checks through the CMC if this call is allowed. 
    //If there is a contract above (the senior) the architectural layering 
    //only the senior contract should be allowed to call the method.
    modifier callAllowed() { //a modifier to reduce code replication

        if (seniorContractName[0] == 0x0 || cmcAddress == 0x0) //no senior set. -> No restriction
            _;

        address seniorContractAddress = CmcReader(cmcAddress).getContract(seniorContractName);

        if (seniorContractAddress == 0x0) //no contract found. Something is wrong
            return;

        if (seniorContractAddress == msg.sender) // this ensures that only the senior can access the function
            _;
    }
}
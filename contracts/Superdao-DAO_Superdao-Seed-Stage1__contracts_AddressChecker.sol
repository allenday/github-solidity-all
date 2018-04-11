pragma solidity ^0.4.8;

//Small utility that batch checks to determine if an address is an external account or a contract address
//This utility is useful for SuperDAO'S prommissory contract batch address input.
//Only regular accounts can recieve ether and can be passed into the withdrawal process
//Only menbers of the internal team initial leadership can pass in batches to avoid spam


/**
* @title Address Checker Contract
* @author ola
* --- Collaborators ---
* @author anthony
*/
contract AddressChecker {

    event ContractAddressesDetected(uint _batchId, uint _badAddresses, bool badBatch);

    address[]Team; //List containing Core team membbers addresses
    uint[] batchNumber; //List of all different batch numbers checked
    uint number = 0; //Number of batches checked

    mapping(uint => address[]) public Batches;

    /**
    * @notice Deploy Address Checker contract setting Core team membbers addresses
    * @dev This is the constructor of the Address Checker contract
    */
    function AddressChecker(){
        Team.push(0x5B44efC8E385371F524E508475eBE741A3858FdC);
        Team.push(0xBe715F6BfbEF7E45583ec6c87d4664d04b5C88Fd);
        Team.push(0x28013bf56eafd00664afc2d9ba649930976227b2);
        Team.push(0xc205B5B867EC8b769836c5D356A058881e3ce056);
        Team.push(0x653851cf3B10E017B25d6bC78bEceEA6d2D3100c);
        Team.push(0x6fC7Ff5baB36b1784047419847edC3Cc9C788b81);
    }

    /**
    * @notice Checking batch of addresses
    * @dev submit a batch of addresses to check if they are contracts or external addresses, triggering an event with the results
    * @param _AddressesToBeChecked (address[])Array of addresses to be checked
    * @return _batchNum (uint)Batch Number for the provided addresses
    * @return _goodOrBadBatch (bool)True if any of batch addresses is a contract address else false
    * @return _numberOfBad Batch (uint)Number fof bad(Contract) addresses in the batch
    */
    function checkAddressBatch(address[] _AddressesToBeChecked)
    external
    NotTeam
    returns (uint _batchNum, bool _goodOrBadBatch, uint _numberOfBad){

        uint badAddresses = 0;
        batchNumber.length = number+1;
        Batches[batchNumber[number]] = _AddressesToBeChecked;
        for (uint i = 0; i < _AddressesToBeChecked.length; i++) {
            if (getSize(_AddressesToBeChecked[i]) > 0){
                badAddresses += 1;
            }
        }

        if(badAddresses > 0){
            ContractAddressesDetected(number, badAddresses, true);
            number += 1;
            return (number,false, badAddresses);
        }

        ContractAddressesDetected(number, badAddresses, false);
        number += 1;
        return (number,true, badAddresses);
    }

    /**
    * @notice Fetching records of batch number: `_batchNumber`
    * @dev Fetch some historical processed batch using the batch number
    * @param _batchNumber (uint)Index of Batch to be retrieved
    * @return (address[])List of Addresses in the retrieved batch
    */
    function specificBatchCheck(uint _batchNumber) external constant returns(address[]) {
        return Batches[batchNumber[_batchNumber]];
    }

    /**
    * @notice Checking Address type of `_addr` by fetching code size
    * @dev Main function of the AddressChecker contract. Retrieve address code size
    * @param _addr (address) Address to retrieve code from
    * @return size (uint) Size of address's code
    */
    function getSize(address _addr) internal returns (uint size) {
        assembly {
            // retrieve the size of the code, this needs assembly
            size := extcodesize(_addr)
            mstore(mload(0x40), size)
        }
    }

    /*
    * Safeguard function.
    * This function gets executed if a transaction with invalid data is sent to
    * the contract or just ether without data.
    */
    function () {
        throw;
    }


    modifier NotTeam(){
      uint found = 0;
      for(uint i=0;i< Team.length;i++){
        if(msg.sender == Team[i])
        found = 1;
      }
      if(found==0)
      throw;
      _;
    }

}

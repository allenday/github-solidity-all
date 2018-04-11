pragma solidity ^0.4.4;

import "./OwnedMortal.sol";

// Gets payment from sender and provedes access to some Treasure value
//
/// @title ValueOwners contract
/// @author alex@kalinkin.info
contract ValueOwners is OwnedMortal {
    // Holds payment for each owner
    mapping (address => uint) ownersPayments;

    // Cost of life access to the ContractHolded value access
    // Can be changed by ContractOwner
    uint public cost;

    function ValueOwners() {
        cost = 10 finney; // Set up initial Cost value
    }

    function () { throw; } // Fallback function

    // Set new ValueCost in Wei
    // Only ContractOwner can change Cost
    //
    /// @param value Amount of Ether to be set as new Cost value
    /// @return New value of Cost
    function setCost(uint value) public isContractOwner() returns(uint newCost) {
        cost = value;
        return cost;
    }

    // Returns balance of defined account address
    /// @param account Address of account
    /// @return balance Value payed from defined address
    function getBalance(address account) constant public isContractOwner() returns (uint balance) {
        return ownersPayments[account];
    }

    // Check is the amount of transaction anouth to pay for Value (equals Cost)
    // Put sender address and sended amount to ownersPayments
    function buyValue() payable public returns (bool success) {
        // check is there payment from user in contract
        // every user get lifetime access to treasure value
        if (ownersPayments[msg.sender] > 0)
            return false;
        // chech that user send enouth value (by current cost)
        if (msg.value != cost) {
            return false;
        }
        ownersPayments[msg.sender] = msg.value;
        return true;
    }

    // Returns amount of user payment
    function payedAmount() constant public returns(uint amount) {
      return ownersPayments[msg.sender];
    }
}

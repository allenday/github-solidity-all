pragma solidity ^0.4.18;

import './StdToken.sol';
import '../util/Ownable.sol';

// @title Multisignature minting - Allows multiple parties to agree on minting before execution.
// @author Philip
// @version 0.1
contract MintToken is StdToken, Ownable {

    uint constant public MAX_OWNER_COUNT = 5;

    // Minting transaction waiting minting
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;

    bool public mintingFinished = false;

    struct Transaction {
        address destination;
        uint value;
//        bytes data;
        bool executed;
    }

/**********************
* Modifiers
***********************/

    modifier ownerExists(address owner) {
        if (!isOwner[owner])
        throw;
        _;
    }

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

/**********************
* Functions
***********************/

    function submitMint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    }

/**********************
* Events
***********************/

    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);
}
pragma solidity ^0.4.11;

import "./Concept.sol";
import "./ConceptRegistry.sol";
import "./lib/StandardToken.sol";
import "./Minter.sol";

/*
@type: contract
@name: UserRegistry
@purpose: To store data about users for easy, secure access and manage token balances
*/
contract FathomToken is StandardToken{
    // address public conceptRegistry;
    ConceptRegistry conceptRegistry;
    string public constant name = "Aha";

    address public minter;
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Notification(address indexed user, address indexed sender, uint indexed topic);
    /*
      0 = You've started an assessment
      1 = Called As A Potential Assessor
      2 = Confirmed for assessing, stake has been taken
      3 = Assessment Cancelled and you have been refunded
      4 = Assessment Has Started
      5 = All have commited; Reveal score
      6 = Consenus was reached; Tokens paid out
      7 = Assessment Finished,
    */

    function FathomToken(address _conceptRegistry, address _initialUser, uint _initialBalance, address _minter) public {
        owner = msg.sender;
        conceptRegistry = ConceptRegistry(_conceptRegistry);
        minter = _minter;
        totalSupply = _initialBalance;
        balances[_initialUser] = _initialBalance;
    }

    function notification(address user, uint topic) public {
        Notification(user, msg.sender, topic);
    }

    //@purpose: To perform payments and staking for assessments
    function takeBalance(address _from,  address _to, uint _amount, address _concept) public returns(bool) {
        require(conceptRegistry.conceptExists(_concept));
        if(msg.sender != _concept) require(Concept(_concept).assessmentExists(msg.sender));

        require(balances[_from] >= _amount
                && balances[_to] + _amount > balances[_to]);
        balances[_from] -= _amount;
        balances[_to] += _amount;
        Transfer(_from, _to, _amount);
        return true;
    }

    function mint(address _to, uint _amount) public returns(bool){
        require(msg.sender == minter);
        require(totalSupply + _amount > totalSupply);

        totalSupply += _amount;
        balances[_to] += _amount;
        Transfer(address(0), _to, _amount);
        return true;
    }

    function changeMinter(address _newMinter) public {
        require(msg.sender == owner);
        minter = _newMinter;
    }

    function transferOwnership(address _newOwner) public {
        require(msg.sender == owner);
        OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

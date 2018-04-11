pragma solidity ^0.4.18;

import '../Utils.sol';
import './interface/ERC23Basic.sol';
import './interface/ERC23Receiver.sol';
import '../../installed_contracts/zeppelin-solidity/contracts/token/BasicToken.sol';

 /**
  *
  * @title Basic token ERC23 
  *        derived from OpenZeppelin solidity library
  * @dev Basic version of StandardToken, with no allowances
  *
  * @dev see also: https://github.com/Dexaran/ERC23-tokens
  *                https://github.com/OpenZeppelin/zeppelin-solidity
  *
  * created by IAM <DEV> (Elky Bachtiar) 
  * https://www.iamdeveloper.io
  *
  *
  * file: Basic23Token.sol
  * location: ERC23/contracts/token/
  *
 */
contract Basic23Token is Utils, ERC23Basic, BasicToken {
  
    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred
    * @param _data is arbitrary data sent with the token transferFrom. Simulates ether tx.data
    * @return bool successful or not
    */
    function transfer(address _to, uint _value, bytes _data) 
        public
        validAddress(_to) 
        notThis(_to)
        greaterThanZero(_value)
        returns (bool success)
    {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);            // Ensure Sender has enough balance to send amount and ensure the sent _value is greater than 0
        require(balances[_to].add(_value) > balances[_to]);  // Detect balance overflow
    
        assert(super.transfer(_to, _value));               //@dev Save transfer

        if (isContract(_to)){
          return contractFallback(msg.sender, _to, _value, _data);
        }
        return true;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) 
        public
        validAddress(_to) 
        notThis(_to)
        greaterThanZero(_value)
        returns (bool success)
    {        
        return transfer(_to, _value, new bytes(0));
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of. 
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) 
        public
        validAddress(_owner) 
        constant returns (uint256 balance)
    {
        return super.balanceOf(_owner);
    }

    //function that is called when transaction target is a contract
    function contractFallback(address _origin, address _to, uint _value, bytes _data) internal returns (bool success) {
        ERC23Receiver reciever = ERC23Receiver(_to);
        return reciever.tokenFallback(msg.sender, _origin, _value, _data);
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) internal returns (bool is_contract) {
        // retrieve the size of the code on target address, this needs assembly
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }
}

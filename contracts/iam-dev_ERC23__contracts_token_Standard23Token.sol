pragma solidity ^0.4.18;

import '../Utils.sol';
import './interface/ERC23.sol';
import './interface/ERC23Receiver.sol';
import './Basic23Token.sol';
import '../../installed_contracts/zeppelin-solidity/contracts/token/StandardToken.sol';

/**
 * @title Standard ERC23 token
 * @dev Implementation of the standard token ERC23.
 *
 * created by IAM <DEV> (Elky Bachtiar) 
 * https://www.iamdeveloper.io
 *
 *
 * file: Standard23Token.sol
 * location: ERC23/contracts/token/
 */
contract Standard23Token is Utils, ERC23, Basic23Token, StandardToken {

    /**
     * @dev Transfer tokens from one address to another
     * @dev Full compliance to ERC-20 and predictable behavior
     * https://docs.google.com/presentation/d/1sOuulAU1QirYtwHJxEbCsM_5LvuQs0YTbtLau8rRxpk/edit#slide=id.p24
     * 
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     * @param _data is arbitrary data sent with the token transferFrom. Simulates ether tx.data
     * @return bool successful or not
   */
    function transferFrom(address _from, address _to, uint256 _value, bytes _data)
        public
        validAddresses(_from, _to) 
        notThis(_to)
        greaterThanZero(_value)
        returns (bool success)
    {
        uint256 allowance = allowed[_from][msg.sender];
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(balances[_to].add(_value) > balances[_to]);  // Detect balance overflow
        require(_value <= allowance);                        // ensure allowed[_from][msg.sender] is greate or equal to send amount to send
        if (_value > 0 && _from != _to) {
            require(transferFromInternal(_from, _to, _value)); // do a normal token transfer
            if (isContract(_to)) {
                return contractFallback(_from, _to, _value, _data);
            }
        }
        return true;
    }


    /**
     * @dev Transfer tokens from one address to another
     * @dev Full compliance to ERC-20 and predictable behavior
     * https://docs.google.com/presentation/d/1sOuulAU1QirYtwHJxEbCsM_5LvuQs0YTbtLau8rRxpk/edit#slide=id.p24
     * 
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     * @return bool successful or not
    */
    function transferFrom(address _from, address _to, uint256 _value)
        public
        validAddresses(_from, _to) 
        greaterThanZero(_value)
        returns (bool success)
    {
        return transferFrom(_from, _to, _value, new bytes(0));
    }

    /**
     * @dev Transfer tokens from one address to another
     * @dev Full compliance to ERC-20 and predictable behavior
     * https://docs.google.com/presentation/d/1sOuulAU1QirYtwHJxEbCsM_5LvuQs0YTbtLau8rRxpk/edit#slide=id.p24
     * 
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     * @return bool successful or not
    */
    function transferFromInternal(address _from, address _to, uint256 _value)
        internal
        validAddresses(_from, _to) 
        greaterThanZero(_value)
        returns (bool success)
    {
        uint256 _allowance = allowed[_from][msg.sender];
        allowed[_from][msg.sender] = _allowance.sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }
}
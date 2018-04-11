pragma solidity ^0.4.11;

import './StandardToken.sol';
import './ERC223ReceivingContract.sol';

/**
 * @title SimpleToken
 * @dev ERC20 Token with features insipred by ERC223 allowing transfers to the contract.
 * Simple version where all tokens are pre-assigned to the creator.
 * `StandardToken` functions.
 */
contract JoyToken is StandardToken {

  string public constant name = "JoyToken";
  string public constant symbol = "JOY";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 21000000 * (10 ** uint256(decimals));

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    function JoyToken() public {
        totalSupply = INITIAL_SUPPLY;           // update total supply
        balances[msg.sender] = INITIAL_SUPPLY;  // give the creator all initial tokens
    }

    // -------------------- features inspired by erc223 idea --------------------

    // Event for transfers that contain additional data
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

    /**
     * Function that is called when a user or another contract wants to transfer funds.
     */
    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.onTokenReceived(msg.sender, _value, _data);
        }
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    /**
     * Standard function transfer similar to ERC20 transfer with no _data .
     * Added due to backwards compatibility reasons.
     */
    function transfer(address _to, uint _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        if (isContract(_to)) {
            bytes memory _empty_data;

            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.onTokenReceived(msg.sender, _value, _empty_data);
        }
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Checking if given address is a contract
     *
     * Check is made by assemby size of bytecode that can be executed on given eth address, only contracts have it
     * _addr any eth valid address
     */
    function isContract(address _addr) internal constant returns (bool) {
        uint codeLength;
        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_addr)
        }
        return (codeLength > 0);
    }
}


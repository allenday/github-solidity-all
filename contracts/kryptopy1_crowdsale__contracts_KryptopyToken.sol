pragma solidity ^0.4.15;

/**
* This smart contract code is Copyright 2017 Kryptopy (http://Kryptopy.com)
*/

import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "zeppelin-solidity/contracts/token/PausableToken.sol";


/**
 * @title KryptopyToken
 *
 * @dev An ERC20 Token that can be minted. All tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 *
 * KPY Tokens have 10 decimal places. The smallest meaningful (and transferable)
 * unit is therefore 0.0000000001 KPY. This unit is called a 'nanoKPY'.
 *
 * 1 KPY = 1 * 10**10 = 1000000000 nanoKPY.
 *
 * Maximum total KPY supply is 40 Million.
 * This is equivalent to 40000000 * 10**10 = 4e+17 krypis.
 *
 * KPY are mintable on demand (as they are being purchased), which means that
 * 40 Million is the maximum.
 *
 * Tokens are initially paused until crowdsale first milestone has been reached.
 */
contract KryptopyToken is MintableToken, PausableToken {

    string public constant NAME = "Kryptopy Token";
    string public constant SYMBOL = "KPY";
    string public constant VERSION = "1.0";
    uint8 public constant DECIMALS = 10;

    //** Maximum total number of tokens ever created */
    uint256 public constant TOKEN_CAP = 40000000 * (10 ** uint256(DECIMALS));
    //** Initial Supply */
    uint256 public constant TOKEN_RESERVE = 5000000 * (10 ** uint256(DECIMALS));

    /**
     * @dev Contructor that gives msg.sender all of existing tokens.
     */
    function KryptopyToken() MintableToken() {
        owner = msg.sender;
        totalSupply = TOKEN_RESERVE;
        balances[owner] = totalSupply;
        Mint(owner, totalSupply);
    }

    /**
     * @dev override MintableToken to check TOKEN_CAP and add a Transfer event from 0x0 to owner.
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool success) {
        if (totalSupply.add(_amount) > TOKEN_CAP) {
            return false;
        }
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /**
    * @dev override BasicToken transfer to check if sender contains enough to transfer
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) returns (bool) {
        if (balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev override StandardToken Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        uint _allowance = allowed[_from][msg.sender];

        if (balances[_from] >= _value && _allowance >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {

            allowed[_from][msg.sender] = _allowance.sub(_value);
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);

            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }
}

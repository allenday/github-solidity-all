pragma solidity ^0.4.15;

/**
 * Welcome to the Wishcoin Contract.
 *
 * Wishcoin is based and built on the foundations of credibility and transparency.
 * We aim to provide excellent support and communication, for more information please visit: http://wishcoin.io
 *
 * Version: 1.0
 *
 * For justification of any code within this Smart Contract, please visit http://wishcoin.io
 *
 * The Wishcoin Smart Contract is open-sourced and licensed under the MIT license. http://opensource.org/licenses/MIT
 *
*/

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Wishcoin is StandardToken, Ownable {

    // Protects against third party overflow attacks
    using SafeMath for uint256;

    // Wishcoin will be born with a total of 500 million coins.
    uint public totalSupply = 50000000000000000; // 500,000,000

    // Allows to track and limit coin inflation
    uint256 lastYearOfInflation = 0;

    // This is what makes Wishcoin, Wishcoin.
    string public constant symbol = "WCN";
    string public constant name = "Wishcoin";
    uint public constant decimals = 8;

    // This mapping stores all the balances within Wishcoin
    mapping(address => uint256) balances;

    //ERC20 Standards allow control of balances by another account, upon approval
    mapping(address => mapping(address => uint256)) allowed;

    /**
    * Wishcoin Funds split in to 10 separate multi-sig accounts for additional security.
    * All Wishcoin Fund accounts will be fully owned and held by the not-for-profit Wishcoin Foundation (UK Legal Entity: 10971660).
    *  ** PLEASE NOTE: Actual addresses will be created and updated here prior to compiling the contract **
    */
    address constant WishcoinFund1 = 0x0000000000000000000000000000000000000000;
    address constant WishcoinFund2 = 0x0000000000000000000000000000000000000000;
    address constant WishcoinFund3 = 0x0000000000000000000000000000000000000000;
    address constant WishcoinFund4 = 0x0000000000000000000000000000000000000000;
    address constant WishcoinFund5 = 0x0000000000000000000000000000000000000000;
    address constant WishcoinFund6 = 0x0000000000000000000000000000000000000000;
    address constant WishcoinFund7 = 0x0000000000000000000000000000000000000000;
    address constant WishcoinFund8 = 0x0000000000000000000000000000000000000000;
    address constant WishcoinFund9 = 0x0000000000000000000000000000000000000000;
    address constant WishcoinFund10 = 0x0000000000000000000000000000000000000000;

    // Wishcoin's which will be distributed during the ICO - which will support multiple payment methods.
    address constant WishcoinICOsale = 0x0000000000000000000000000000000000000000;

    // Initialize the economy
    function Wishcoin() {
        balances[WishcoinICOsale] = balances[WishcoinICOsale].add(20000000000000000); // 200,000,000 Wishcoin's for sale during ICO

        balances[WishcoinFund1] = balances[WishcoinFund1].add(2500000000000000); // 250,00,000 Wishcoin's into the 1st fund owned by the Wishcoin Foundation
        balances[WishcoinFund2] = balances[WishcoinFund2].add(2500000000000000); // 250,00,000 Wishcoin's into the 2nd fund owned by the Wishcoin Foundation
        balances[WishcoinFund3] = balances[WishcoinFund3].add(2500000000000000); // 250,00,000 Wishcoin's into the 3rd fund owned by the Wishcoin Foundation
        balances[WishcoinFund4] = balances[WishcoinFund4].add(2500000000000000); // 250,00,000 Wishcoin's into the 4th fund owned by the Wishcoin Foundation
        balances[WishcoinFund5] = balances[WishcoinFund5].add(2500000000000000); // 250,00,000 Wishcoin's into the 5th fund owned by the Wishcoin Foundation
        balances[WishcoinFund6] = balances[WishcoinFund6].add(2500000000000000); // 250,00,000 Wishcoin's into the 6th fund owned by the Wishcoin Foundation
        balances[WishcoinFund7] = balances[WishcoinFund7].add(2500000000000000); // 250,00,000 Wishcoin's into the 7th fund owned by the Wishcoin Foundation
        balances[WishcoinFund8] = balances[WishcoinFund8].add(2500000000000000); // 250,00,000 Wishcoin's into the 8th fund owned by the Wishcoin Foundation
        balances[WishcoinFund9] = balances[WishcoinFund9].add(2500000000000000); // 250,00,000 Wishcoin's into the 9th fund owned by the Wishcoin Foundation
        balances[WishcoinFund10] = balances[WishcoinFund10].add(2500000000000000);  // 250,00,000 Wishcoin's into the 10th fund owned by the Wishcoin Foundation

        balances[msg.sender] = balances[msg.sender].add(5000000000000000); // 50,000,000 Wishcoin's which will be distributed between the Wishcoin Investors
    }

    // Returns the number of Wishcoin's within the requested wallet
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // Transfers Wishcoin between two wallets.
    function transfer(address _to, uint256 _value) returns (bool success) {
        // Pre-transfer verification checks
        require(
            balances[msg.sender] >= _value
            && _value > 0
        );

        // Perform the transfer of Wishcoin's
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        // Fire the event to the contract
        Transfer(msg.sender, _to, _value);

        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        // Pre-transfer verification checks
        require(
            allowed[_from][msg.sender] >= _value
            && balances[_from] >= _value
            && _value > 0
        );

        // Perform the transfer of Wishcoin's
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        // Deduct the authorised transfer from the senders budget
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        // Fire the event to the contract
        Transfer(_from, _to, _value);

        return true;
    }

    // Provide approval for another account to manage Wishcoin's
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender,_spender, _value);
        return true;
    }

    // Return the balance allowed for management by an approved account.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * This runs the annual inflation for Wishcoin, to ensure growth after 10 years.
     * This function ensures that this inflation call can only be initiated by the contract owner.
     * This also records the year in which this function was last called, and only allows this function
     * to be called once a year.
     */
    function runAnnualInflation() onlyOwner public returns (bool success) {
        // Ensure inflation cannot be run before the year 2027, based on Unix Epoch Time
        // https://en.wikipedia.org/wiki/Unix_time
        require(
            (now / 1 years) >= 57
        );

        // ensure this can only be run once a year
        require(
            lastYearOfInflation < (now / 1 years)
        );

        /**
         * create 20 million Wishcoin's as inflation and distribute evenly between the Wishcoin Foundation multi-sig accounts
         * (Inflation starts after 10 years at only 5% of the coin total supply and therefore reduces in percentage annually)
         * Numbers below takes into account the 8 decimal places of Wishcoin
         */
        mint(WishcoinFund1, 200000000000000); // 2,000,000 Wishcoin's into the 1st fund owned by the Wishcoin Foundation
        mint(WishcoinFund2, 200000000000000); // 2,000,000 Wishcoin's into the 2nd fund owned by the Wishcoin Foundation
        mint(WishcoinFund3, 200000000000000); // 2,000,000 Wishcoin's into the 3rd fund owned by the Wishcoin Foundation
        mint(WishcoinFund4, 200000000000000); // 2,000,000 Wishcoin's into the 4th fund owned by the Wishcoin Foundation
        mint(WishcoinFund5, 200000000000000); // 2,000,000 Wishcoin's into the 5th fund owned by the Wishcoin Foundation
        mint(WishcoinFund6, 200000000000000); // 2,000,000 Wishcoin's into the 6th fund owned by the Wishcoin Foundation
        mint(WishcoinFund7, 200000000000000); // 2,000,000 Wishcoin's into the 7th fund owned by the Wishcoin Foundation
        mint(WishcoinFund8, 200000000000000); // 2,000,000 Wishcoin's into the 8th fund owned by the Wishcoin Foundation
        mint(WishcoinFund9, 200000000000000); // 2,000,000 Wishcoin's into the 9th fund owned by the Wishcoin Foundation
        mint(WishcoinFund10, 200000000000000); // 2,000,000 Wishcoin's into the 10th fund owned by the Wishcoin Foundation

        // Stop inflation being run more than once a year
        lastYearOfInflation = now / 1 years;

        return true;
    }

    /**
    * This function allows Wishcoin's to be minted (created).
    * This function can only be called by the owner of the contract, and only via the runAnnualInflation() function,
    * as this is a private function.
    */
    function mint(address _to, uint256 _amount) onlyOwner private returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /**
    * A helper function which allows easy call to the last year runAnnualInflation() was run.
    */
    function getLastYearOfInflation() constant returns (uint256) {
        if(lastYearOfInflation == 0)
        {
            return lastYearOfInflation;
        }

        return lastYearOfInflation + 1970; //Unix Epoch
    }

    event Transfer(address indexed _fromt, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Mint(address indexed to, uint256 amount);
}

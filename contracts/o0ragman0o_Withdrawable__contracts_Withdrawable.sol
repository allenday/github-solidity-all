/******************************************************************************\

file:   Withdrawable.sol
ver:    0.4.2
updated:25-Oct-2017
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

A contract interface presenting an API for withdrawal functionality of ether
balances and inter-contract pull and push payments. Caller permissions should
be left permissive to facilitate 'clearing house' operations.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Change Log
----------
* removed `acceptingDeposits` in accordance to draft EIP disallowing reverting
upon deposit.

\******************************************************************************/

pragma solidity ^0.4.13;

// The minimum interface supporting pull payments with deposits and withdrawl
// events
interface WithdrawableMinItfc
{
//
// Events
//

    /// @dev Logged upon receiving a deposit
    /// @param _from The address from which value has been recieved
    /// @param _value The value of ether received
    event Deposit(address indexed _from, uint _value);
    
    /// @dev Logged upon a withdrawal
    /// @param _from the address accounted to have owned the ether
    /// @param _to Address to which value was sent
    /// @param _value The value in ether which was withdrawn
    event Withdrawal(address indexed _from, address indexed _to, uint _value);

    /// @notice withdraw total balance from account `msg.sender`
    /// @return success
    function withdrawAll() public returns (bool);
}

// The extended interface of optional API state variables, functions, and events
interface WithdrawableItfc
{
//
// Events
//

    /// @dev Logged upon receiving a deposit
    /// @param _from The address from which value has been recieved
    /// @param _value The value of ether received
    event Deposit(address indexed _from, uint _value);
    
    /// @dev Logged upon a withdrawal
    /// @param _from the address accounted to have owned the ether
    /// @param _to Address to which value was sent
    /// @param _value The value in ether which was withdrawn
    event Withdrawal(address indexed _from, address indexed _to, uint _value);

//
// Function Abstracts
//

    /// @param _addr An ethereum address
    /// @return The balance of ether held in the contract for `_addr`
    function etherBalanceOf(address _addr) public view returns (uint);
    
    /// @notice withdraw total balance from account `msg.sender`
    /// @return Boolean success value
    function withdrawAll() public returns (bool);

    /// @notice Withdraw `_value` from account `msg.sender`
    /// @param _value the value to withdraw
    /// @return Boolean success value
    function withdraw(uint _value) public returns (bool);
    
    /// @notice Withdraw `_value` from account `msg.sender` and send `_value` to
    /// address `_to`
    /// @param _to a recipient address
    /// @param _value the value to withdraw
    /// @return Boolean success value
    function withdrawTo(address _to, uint _value) public returns (bool);
    
    /// @notice Withdraw total balance for an array of accounts
    /// @param _addrs An array of address to withraw for
    /// @return Boolean success value
    function withdrawAllFor(address[] _addrs) public returns (bool);

    /// @notice Withdraw respective values for an array of addresses
    /// @param _addrs An array of address to withraw for
    /// @param _values An array of values to withdraw
    /// @dev Values must be valid or the call will throw
    /// @return Boolean success value
    function withdrawFor(address[] _addrs, uint[] _values) public returns (bool);
    
    /// @notice Have this contract withdraw from contract at `_from` 
    /// @param _from a contract address where this contract's value is held
    /// @return Boolean success value
    function withdrawAllFrom(address _from) public returns (bool);
    
    /// @notice Have this contract withdraw `_value` from contract at `_from` 
    /// @param _from a contract address where this contract's value is held
    /// @param _value the value to withdraw
    /// @return Boolean success value
    function withdrawFrom(address _from, uint _value) public returns (bool);
}


// Example implementation
contract Withdrawable is WithdrawableItfc
{
    // Withdrawable contracts should have an owner
    address public owner;

    function Withdrawable()
        public
    {
        owner = msg.sender;
    }
    
    // Payable on condition that contract is accepting deposits
    function ()
        public
        payable
    {
        if (msg.value > 0) {
            Deposit(msg.sender, msg.value);
        }
    }
    
    // Return an ether balance of an address
    function etherBalanceOf(address _addr)
        public
        view
        returns (uint)
    {
        return _addr == owner ? this.balance : 0;    
    }
    
    // Withdraw a value of ether awarded to the caller's address
    function withdraw(uint _value)
        public
        returns (bool)
    {
        // Return on false if transfer would have reverted
        if (_value > etherBalanceOf(msg.sender)) return false;
        Withdrawal(msg.sender, msg.sender, _value);
        msg.sender.transfer(_value);
        return true;
    }
    
    // Withdraw entire ether balance from caller's account to caller's address
    function withdrawAll()
        public
        returns (bool)
    {
        uint value = etherBalanceOf(msg.sender);
        if (value > 0) {
            msg.sender.transfer(value);
            Withdrawal(msg.sender, msg.sender, value);
        }
        return true;
    }
    
    // Withdraw a value of ether sending it to the specified address
    function withdrawTo(address _to, uint _value)
        public
        returns (bool)
    {
        if (_value > etherBalanceOf(msg.sender)) return false;
        Withdrawal(msg.sender, _to, _value);
        _to.transfer(_value);
        return true;
    }
    
    // Push an entire balance of an address to that address
    function withdrawAllFor(address[] _addrs)
        public
        returns (bool)
    {
        for(uint i; i < _addrs.length; i++) {
            Withdrawal(this, _addrs[i], etherBalanceOf(_addrs[i]));
            _addrs[i].transfer(etherBalanceOf(_addrs[i]));
        }
        return true;        
    }


    // Push a payment to an address of which has awarded ether
    function withdrawFor(address[] _addrs, uint[] _values)
        public
        returns (bool)
    {
        if(_addrs.length != _values.length) return false;
        address addr;
        uint value;
        for(uint i; i < _addrs.length; i++) {
            addr = _addrs[i];
            value = _values[i];
            require(etherBalanceOf(addr) >= value);
            Withdrawal(msg.sender, addr, value);
            addr.transfer(value);
        }
        return true;
    }
    
    // Withdraw all awarded ether from an external contract in which this
    // instance holds a balance
    function withdrawAllFrom(address _kAddr)
        public
        returns (bool)
    {
        uint currBal = this.balance;
        WithdrawableMinItfc(_kAddr).withdrawAll();
        Deposit(_kAddr, this.balance - currBal);
        return true;
    }
    
    // Withdraw ether from an external contract in which this instance holds
    // a balance
    function withdrawFrom(address _kAddr, uint _value)
        public
        returns (bool)
    {
        uint currBal = this.balance;
        if(!WithdrawableItfc(_kAddr).withdraw(_value)) return false;
        Deposit(_kAddr, this.balance - currBal);
        return true;
    }
}
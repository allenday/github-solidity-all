pragma solidity ^0.4.2;

import "./priced.sol";

contract accessRestricted is priced {
    // These will be assigned at the construction
    // phase, where `msg.sender` is the account
    // creating this contract.
    address public owner = msg.sender;
    uint public creationTime = now;

    // Modifiers can be used to change
    // the body of a function.
    // If this modifier is used, it will
    // prepend a check that only passes
    // if the function is called from
    // a certain address.
    modifier onlyBy(address _account)
    {
        if (msg.sender != _account)
            throw;
        // Do not forget the "_;"! It will
        // be replaced by the actual function
        // body when the modifier is used.
        _;
    }

    modifier eitherBy(address _account1, address _account2)
    {
        if (msg.sender != _account1 ||
            msg.sender != _account2)
            throw;

        _;
           
    }

    /// Make `_newOwner` the new owner of this
    /// contract.
    function changeOwner(address _newOwner)
    onlyBy(owner)
    {
        owner = _newOwner;
    }

    modifier onlyAfter(uint _time) {
        if (now < _time) throw;
        _;
    }

    /// Erase ownership information.
    /// May only be called 6 weeks after
    /// the contract has been created.
    function disown()
    onlyBy(owner)
    onlyAfter(creationTime + 6 weeks)
    {
        delete owner;
    }

    function forceOwnerChange(address _newOwner)
    costs(200 ether)
    {
        owner = _newOwner;
        // just some example condition
        if (uint(owner) & 0 == 1)
            // This did not refund for Solidity
            // before version 0.4.0.
            return;
            // refund overpaid fees
    }
}


pragma solidity ^0.4.11;

import "./zeppelin/ownership/Ownable.sol";
import "./zeppelin/token/StandardToken.sol";

/// @title Papyrus token contract (PPR).
contract PapyrusToken is StandardToken, Ownable {

    // EVENTS

    event TransferableChanged(bool transferable);

    // PUBLIC FUNCTIONS

    function PapyrusToken(address[] _wallets, uint256[] _amounts) {
        require(_wallets.length == _amounts.length && _wallets.length > 0);
        uint i;
        uint256 sum = 0;
        for (i = 0; i < _wallets.length; ++i) {
            sum = sum.add(_amounts[i]);
        }
        require(sum == PPR_LIMIT);
        totalSupply = PPR_LIMIT;
        for (i = 0; i < _wallets.length; ++i) {
            balances[_wallets[i]] = _amounts[i];
        }
    }

    // If ether is sent to this address, send it back
    function() { revert(); }

    // Check transfer ability and sender address before transfer
    function transfer(address _to, uint _value) canTransfer returns (bool) {
        return super.transfer(_to, _value);
    }

    // Check transfer ability and sender address before transfer
    function transferFrom(address _from, address _to, uint _value) canTransfer returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /// @dev Change ability to transfer tokens by users.
    function setTransferable(bool _transferable) onlyOwner {
        require(transferable != _transferable);
        transferable = _transferable;
        TransferableChanged(transferable);
    }

    // MODIFIERS

    modifier canTransfer() {
        require(transferable || msg.sender == owner);
        _;
    }

    // FIELDS

    // Standard fields used to describe the token
    string public name = "Papyrus Token";
    string public symbol = "PPR";
    string public version = "H0.1";
    uint8 public decimals = 18;

    // At the start of the token existence it is transferable
    bool public transferable = true;

    // Amount of supplied tokens is constant and equals to 1 000 000 000 PPR
    uint256 private constant PPR_LIMIT = 10**27;
}

pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';


contract IouRootsReservationToken is MintableToken {

    string public name;
    
    string public symbol;
    
    uint8 public decimals;

    // This is not a ROOT token.
    // This token is used for the preallocation of the ROOT token, that will be issued later.
    // Only Owner can transfer balances and mint ROOTS without payment.
    // Owner can finalize the contract by `finishMinting` transaction
    function IouRootsReservationToken(string _name, string _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function transfer(address _to, uint _value) onlyOwner returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) onlyOwner returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}

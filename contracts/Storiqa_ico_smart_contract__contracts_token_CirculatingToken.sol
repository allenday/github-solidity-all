pragma solidity 0.4.15;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';


/// @title StandardToken which circulation can be delayed and started by another contract.
/// @dev To be used as a mixin contract.
/// The contract is created in disabled state: circulation is disabled.
contract CirculatingToken is StandardToken {

    event CirculationEnabled();

    modifier requiresCirculation {
        require(m_isCirculating);
        _;
    }


    // PUBLIC interface

    function transfer(address _to, uint256 _value) requiresCirculation returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) requiresCirculation returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) requiresCirculation returns (bool) {
        return super.approve(_spender, _value);
    }


    // INTERNAL functions

    function enableCirculation() internal returns (bool) {
        if (m_isCirculating)
            return false;

        m_isCirculating = true;
        CirculationEnabled();
        return true;
    }


    // FIELDS

    /// @notice are the circulation started?
    bool public m_isCirculating;
}

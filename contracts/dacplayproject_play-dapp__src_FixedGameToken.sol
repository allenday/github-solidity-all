pragma solidity ^0.4.13;

import "ds-token/token.sol";
import "./PLS.sol";

contract FixedGameToken is DSToken, Controlled, ERC223ReceivingContract {
    PLS public pls;
    uint public collateral;
    uint public ratio;  // collateral = supply * ratio;

    function FixedGameToken(bytes32 _symbol, uint _ratio, address _pls) DSToken(_symbol)
    {
        pls = PLS(_pls);

        ratio = _ratio;
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public
    {
        // if receiving pls, redirect to buy.
        if ( msg.sender == address(pls) )
        {
            // TODO: redirect to mint;
        }
        // if receiving token, redirect to sell.
        else if ( msg.sender == address(this) )
        {
            // TODO: redirect to burn;
        } else {
            // throw
            revert();
        }

    }

    function mint(address _beneficiary, uint _wad) auth stoppable {
        uint plsCount = mul(_wad, ratio);

        // approve required ahead;
        pls.transferFrom(msg.sender, this, plsCount);
        collateral = add(collateral, plsCount);

        super.mint(_beneficiary, _wad);

        Transfer(0, _beneficiary, _wad);
    }
    function burn(address _beneficiary, uint _wad) auth stoppable {
        uint plsCount = mul(_wad, ratio);

        // approve required ahead;
        pls.transfer(_beneficiary, plsCount);
        collateral = sub(collateral, plsCount);

        super.burn(msg.sender, _wad);

        Transfer(msg.sender, 0, _wad);
    }
}
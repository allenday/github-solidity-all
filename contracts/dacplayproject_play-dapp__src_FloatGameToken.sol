pragma solidity ^0.4.13;

import "ds-token/token.sol";
import "./PLS.sol";

contract FloatGameToken is DSToken, Controlled, ERC223ReceivingContract {
    PLS public pls;
    uint public collateral;

    function FloatGameToken(bytes32 _symbol, address _pls) DSToken(_symbol)
    {
        pls = PLS(_pls);
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public
    {
        // if receiving pls, redirect to buy.
        if ( msg.sender == address(pls) )
        {
            buyToken(_from, _value, 0, false);
        }
        // if receiving token, redirect to sell.
        else if ( msg.sender == address(this) )
        {
            sellToken(_from, _value, 0, false);
        } else {
            // throw
            revert();
        }
    }

    /// @notice buy this token using pls.
    /// @param _from The buyer
    /// @param _value The amount of pls buyer uses to buy
    /// @param _minReturn The minimal amount of token the buyer want to get, if less this deal will fail and cancel.
    /// @return False if the controller does not authorize the transfer
    function buyToken(address _from, uint _value, uint _minReturn, bool transfered) internal
    {
        uint coll = pls.balanceOf(this);
        require( coll >= collateral );

        uint back = wdiv( wmul( _value, totalSupply() ), collateral );

        require(back >= _minReturn);

        // approve required ahead
        if ( !transfered )
        {
            pls.transferFrom(_from, this, _value);
            collateral = add(collateral, _value);
        }        

        mint(_from, back);
    }

    /// @notice buy this token using pls.
    /// @param _from The buyer
    /// @param _value The amount of pls buyer uses to buy
    /// @param _minReturn The minimal amount of token the buyer want to get, if less this deal will fail and cancel.
    /// @return False if the controller does not authorize the transfer
    function sellToken(address _from, uint _value, uint _minReturn, bool transfered) internal
    {
        uint coll = pls.balanceOf(this);
        require( coll >= collateral );

        uint back = wdiv( wmul( _value, collateral ), totalSupply() );

        require(back >= _minReturn);

        // approve required ahead
        if ( !transfered )
        {
            this.transferFrom(_from, this, _value);
            burn(this, _value);
        }

        pls.transferFrom(this, _from, back);
        collateral = sub(collateral, back);
    }

    // function price() return


    function mint(address _guy, uint _wad) auth stoppable {
        super.mint(_guy, _wad);

        Transfer(0, _guy, _wad);
    }

    function burn(address _guy, uint _wad) auth stoppable {
        super.burn(_guy, _wad);

        Transfer(_guy, 0, _wad);
    }

}
pragma solidity ^0.4.11;

import "./ERC20.sol";
/*import "./SafeMath.sol";*/

contract Exchange {

  enum Status { OPEN, CANCELED, CLOSED }
  enum Side { ASK, BID }

  struct Offer {
    Side side;
    address token;
    address offeror;
    uint256 amount;
    uint256 value;
    Status status;
  }

  Offer[] public offers;

  event Open(uint256 id);
  event Cancel(uint256 id);
  event Close(uint256 id);
  event Debug(string message, uint256[] nums);

  function open(Side _side, address _token, uint256 _amount, uint256 _value) payable {

    ERC20 token = ERC20(_token);

    if (_side == Side.ASK){
      // verify seller has permitted contract to transfer tokens
      require( token.allowance(msg.sender, this) >= _amount );
      // take custody of tokens
      assert( token.transferFrom(msg.sender, this, _amount) );
    }

    Offer memory o;
    o.side = _side;
    o.token = token;
    o.offeror = msg.sender;
    o.amount = _amount;
    o.value = _side == Side.ASK ? _value : msg.value;
    o.status = Status.OPEN;
    // push returns length, so id is last item index or length - 1
    uint256 id = offers.push(o) - 1;
    Open(id);
  }

  function cancel(uint256[] _ids) {
    for(uint i = 0; i < _ids.length; i++) {
      uint id = _ids[i];
      Offer o = offers[id];
      // only offeror can cancel
      require( msg.sender == o.offeror );
      // can only cancel an open offer
      require( o.status == Status.OPEN );
      if (o.side == Side.ASK) {
        // send token back to offeror
        assert( ERC20(o.token).transfer(msg.sender, o.amount) );
      } else {  // is Side.BID
        // send eth back to offeror
        o.offeror.transfer( o.value );
      }
      // set canceled
      o.status = Status.CANCELED;
      Cancel(id);
    }
  }

  function fill(uint256[] _ids) payable {
    Side side;
    ERC20 token;
    uint256 remaining;

    for(uint i = 0; i < _ids.length; i++) {
      uint id = _ids[i];
      Offer o = offers[id];

      // all must be of same side and token
      if ( i == 0 ) {
        side = o.side;
        token = ERC20(o.token);
        // Side.BID fills should not send ether
        require( side == Side.ASK || msg.value == 0 );
        remaining = side == Side.ASK ? msg.value : token.allowance(msg.sender, this);
      } else {
        require( o.side == side );
        require( o.token == address(token) );
      }

      // check order is open
      if ( o.status != Status.OPEN ) continue;

      if (o.side == Side.ASK) {
        // skip offer if we don't have enough
        // TODO fill partial orders
        if ( remaining < o.value ) {
          assert( partialAsk(o, remaining) );
          remaining = 0;
          break;
        } else {
          // reduce balance to reflect this order
          remaining -= o.value;
          o.status = Status.CLOSED;
          // send tokens to buyer
          assert( token.transfer(msg.sender, o.amount) );
          // and eth to seller
          o.offeror.transfer( o.value );
          Close(id);
        }
      } else {  // is Side.BID
        // skip offer if we don't have enough
        // TODO fill partial orders
        if( remaining < o.amount ) {
          assert( partialBid(o, remaining) );
          remaining = 0;
          break;
        } else {
          // reduce balance to reflect this order
          remaining -= o.amount;
          o.status = Status.CLOSED;
          // transfer seller tokens to buyer (offeror)
          assert( token.transferFrom(msg.sender, o.offeror, o.amount) );
          // and eth to seller
          msg.sender.transfer( o.value );
          Close(id);
        }
      }
    }

    // if any eth remaining, return to sender
    if ( side == Side.ASK && remaining > 0  ) msg.sender.transfer( remaining );
  }

  function partialAsk(Offer o, uint256 remaining) internal returns (bool) {
    uint amount = remaining * o.amount / o.value;
    o.value -= remaining;
    o.amount -= amount;
    // send tokens to buyer
    assert( ERC20(o.token).transfer(msg.sender, amount) );
    // and eth to seller
    o.offeror.transfer( remaining );
    return true;
  }

  function partialBid(Offer o, uint256 remaining) internal returns (bool) {
    uint value = remaining * o.value / o.amount;
    o.value -= value;
    o.amount -= remaining;
    // transfer seller tokens to buyer (offeror)
    assert( ERC20(o.token).transferFrom(msg.sender, o.offeror, remaining) );
    // and eth to seller
    msg.sender.transfer( value );
    return true;
  }

}

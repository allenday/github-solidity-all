pragma solidity ^0.4.15;

contract owned
{
  address public owner;
  function owned() { owner = msg.sender; }

  modifier onlyOwner {
    require( msg.sender == owner );
    _;
  }

  function changeOwner( address newOwner ) onlyOwner { owner = newOwner; }
  function closedown() onlyOwner { selfdestruct( owner ); }
}

interface Membership {
  function isMember( address pusher ) returns (bool);
}

contract Publisher is owned
{
  event Published( bytes receiverpubkey, string ipfshash );
  event Fee( uint256 fee );

  Membership public membership;
  uint256 public fee;

  function Publisher() { fee = 0; }

  function setFee( uint256 _fee ) onlyOwner {
    fee = _fee;
    Fee( fee );
  }

  function setMembershipContract( address _contract ) onlyOwner
  {
    membership = Membership(_contract);
  }

  function() payable { revert(); }

  function publish( bytes receiverpubkey, string ipfshash ) payable
  {
    require( msg.value >= fee );
    require( membership.isMember(msg.sender) );

    Published( receiverpubkey, ipfshash );
  }
}


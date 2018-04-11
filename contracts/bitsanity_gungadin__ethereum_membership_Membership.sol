pragma solidity ^0.4.15;

contract owned
{
  address public owner;

  modifier isOwner {
    require( msg.sender == owner );
    _;
  }

  function owned() { owner = msg.sender; }
  function changeOwner( address newOwner ) isOwner { owner = newOwner; }
  function closedown() isOwner { selfdestruct( owner ); }
}

// ==========================================================================
// List of members known by Ethereum address. Balance must be greater than
// zero to be valid. Owner may adjust fees.
//
// To suspend a member means setting their balance to zero. Member must be
// reapproved and repay to reestablish membership.
// ==========================================================================

contract Membership is owned
{
  event Approved( address indexed newmember );
  event Suspended( address indexed member );
  event Fee( uint256 fee );

  mapping( address => bool ) public approvals;
  mapping( address => uint256 ) public balances;

  uint256 public fee;
  address public treasury;

  function Membership() {}

  function setFee( uint256 _fee ) isOwner
  {
    fee = _fee;
    Fee( fee );
  }

  function setTreasury( address _treasury ) isOwner { treasury = _treasury; }

  function approve( address newMember ) isOwner
  {
    approvals[ newMember] = true;
    Approved( newMember );
  }

  function suspend( address oldMember ) isOwner
  {
    approvals[oldMember] = false;
    balances[oldMember] = 0;
    Suspended( oldMember );
  }

  function isMember( address _addr ) constant returns (bool)
  {
    return approvals[_addr] && 0 < balances[_addr];
  }

  function() payable
  {
    require( approvals[msg.sender] && msg.value >= fee );
    balances[msg.sender] += msg.value;

    if (treasury != address(0)) require( treasury.send(msg.value) );
  }

  function withdraw( uint256 amount ) isOwner returns (bool)
  {
    return owner.send( amount );
  }

}


/// Incomplete: a test contract for Partnership
/// Doesn't allow deposits after the first time, allows proxy calls.
pragma solidity ^0.4.18;
contract Incomplete
{
  // The fund can only receive money once
  bool public once;

  function Incomplete() public {
    once = true;
  }

  // Used to call Partnership.withdrawal in a failure condition
  function run(uint value, bytes data) public {
    require(this.call.value(value)(data));
  }

  // This executes when funds are sent to the contract
  function() public payable {
    require(once);

    // Fail forevermore
    once = false;
  }
}


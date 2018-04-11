
pragma solidity ^0.4.16;

import "zeppelin-solidity/contracts/token/StandardToken.sol";


contract DEST  is StandardToken {

  // Constants
  // =========

  string public constant name = "Decentralized Escrow Token";
  string public constant symbol = "DEST";
  uint   public constant decimals = 18;

  uint public constant ETH_MIN_LIMIT = 500 ether;
  uint public constant ETH_MAX_LIMIT = 1500 ether;

  uint public constant START_TIMESTAMP = 1503824400; // 2017-08-27 09:00:00 UTC
  uint public constant END_TIMESTAMP   = 1506816000; // 2017-10-01 00:00:00 UTC

  address public constant wallet = 0x51559EfC1AcC15bcAfc7E0C2fB440848C136A46B;


  // State variables
  // ===============

  uint public ethCollected;
  mapping (address=>uint) ethInvested;


  // Constant functions
  // =========================

  function hasStarted() public constant returns (bool) {
    return now >= START_TIMESTAMP;
  }


  // Payments are not accepted after ICO is finished.
  function hasFinished() public constant returns (bool) {
    return now >= END_TIMESTAMP || ethCollected >= ETH_MAX_LIMIT;
  }


  // Investors can move their tokens only after ico has successfully finished
  function tokensAreLiquid() public constant returns (bool) {
    return (ethCollected >= ETH_MIN_LIMIT && now >= END_TIMESTAMP)
      || (ethCollected >= ETH_MAX_LIMIT);
  }


  function price(uint _v) public constant returns (uint) {
    return // poor man's binary search
      _v < 7 ether
        ? _v < 3 ether
          ? _v < 1 ether
            ? 1000
            : _v < 2 ether ? 1005 : 1010
          : _v < 4 ether
            ? 1015
            : _v < 5 ether ? 1020 : 1030
        : _v < 14 ether
          ? _v < 10 ether
            ? _v < 9 ether ? 1040 : 1050
            : 1080
          : _v < 100 ether
            ? _v < 20 ether ? 1110 : 1150
            : 1200;
  }


  // Public functions
  // =========================

  function() public payable {
    require(hasStarted() && !hasFinished());
    require(ethCollected + msg.value <= ETH_MAX_LIMIT);

    ethCollected += msg.value;
    ethInvested[msg.sender] += msg.value;

    uint _tokenValue = msg.value * price(msg.value);
    balances[msg.sender] += _tokenValue;
    totalSupply += _tokenValue;
    Transfer(0x0, msg.sender, _tokenValue);
  }


  // Investors can get refund if ETH_MIN_LIMIT is not reached.
  function refund() public {
    require(ethCollected < ETH_MIN_LIMIT && now >= END_TIMESTAMP);
    require(balances[msg.sender] > 0);

    totalSupply -= balances[msg.sender];
    balances[msg.sender] = 0;
    uint _ethRefund = ethInvested[msg.sender];
    ethInvested[msg.sender] = 0;
    msg.sender.transfer(_ethRefund);
  }


  // Owner can withdraw all the money after min_limit is reached.
  function withdraw() public {
    require(ethCollected >= ETH_MIN_LIMIT);
    wallet.transfer(this.balance);
  }


  // ERC20 functions
  // =========================

  function transfer(address _to, uint _value) public returns (bool)
  {
    require(tokensAreLiquid());
    return super.transfer(_to, _value);
  }


  function transferFrom(address _from, address _to, uint _value)
    public returns (bool)
  {
    require(tokensAreLiquid());
    return super.transferFrom(_from, _to, _value);
  }


  function approve(address _spender, uint _value)
    public returns (bool)
  {
    require(tokensAreLiquid());
    return super.approve(_spender, _value);
  }
}

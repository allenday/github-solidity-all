pragma solidity ^0.4.15;

import "./base/ERC23Contract.sol";
import "./base/Lib.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

// Ethereum match, simple social experiment. Because game theory is fun :)
// If you send ETH in the exact same amount as the contract balance, you get yours back plus half the contract balance (minus 5%).
// If you send ETH NOT in the exact same amount as the contract balance (i.e. someone else beat you to the punch),
//   current Matchmaster gets to keep it (minus 5%).
// Any time the contract balance falls below the "mastery threshold" (10 finney aka .01 ETH), someone else can become new Matchmaster
//   by sending >= 10 finney w/ a mastery() tx, and they will then receive the Matchmaster payouts.
// The creator's 5% is necessary, else current Matchmaster could just repeatedly send balance amount to contract
//   and never lose to other matchmakers.
contract EthMatch is Ownable, ERC23Contract {
  using SafeMath for uint256;

  uint256 public constant MASTERY_THRESHOLD = 10 finney; // new master allowed if balance falls below this (10 finney == .01 ETH)
  uint256 public constant PAYOUT_PCT = 95; // % to winner (rest to creator)

  uint256 public startTime; // start timestamp when matches may begin
  address public master; // current Matchmaster
  uint256 public gasReq; // require same gas every time in maker()

  event MatchmakerPrevails(address indexed matchmaster, address indexed matchmaker, uint256 sent, uint256 actual, uint256 winnings);
  event MatchmasterPrevails(address indexed matchmaster, address indexed matchmaker, uint256 sent, uint256 actual, uint256 winnings);
  event MatchmasterTakeover(address indexed matchmasterPrev, address indexed matchmasterNew, uint256 balanceNew);

  // can be funded at init if desired
  function EthMatch(uint256 _startTime) public payable {
    require(_startTime >= now);

    startTime = _startTime;
    master = msg.sender; // initial
    gasReq = 42000;
  }

  // ensure proper state
  modifier isValid(address _addr) {
    require(_addr != 0x0);
    require(!Lib.isContract(_addr)); // ban contracts
    require(now >= startTime);

   _;
  }

  // fallback function
  // make a match
  function () public payable {
    maker(msg.sender);
  }

  // make a match (and specify payout address)
  function maker(address _addr) isValid(_addr) public payable {
    require(msg.gas >= gasReq); // require same gas every time (overages auto-returned)

    uint256 weiPaid = msg.value;
    require(weiPaid > 0);

    uint256 balPrev = this.balance.sub(weiPaid);

    if (balPrev == weiPaid) {
      // maker wins
      uint256 winnings = weiPaid.add(balPrev.div(2));
      pay(_addr, winnings);
      MatchmakerPrevails(master, _addr, weiPaid, balPrev, winnings);
    } else {
      // master wins
      pay(master, weiPaid);
      MatchmasterPrevails(master, _addr, weiPaid, balPrev, weiPaid);
    }
  }

  // send proceeds
  function pay(address _addr, uint256 _amount) internal {
    if (_amount == 0) {
      return; // amount actually could be 0, e.g. initial funding or if balance is totally drained
    }

    uint256 payout = _amount.mul(PAYOUT_PCT).div(100);
    _addr.transfer(payout);

    uint256 remainder = _amount.sub(payout);
    owner.transfer(remainder);
  }

  // become the new master
  function mastery() public payable {
    mastery(msg.sender);
  }

  // become the new master (and specify payout address)
  function mastery(address _addr) isValid(_addr) public payable {
    uint256 weiPaid = msg.value;
    require(weiPaid >= MASTERY_THRESHOLD);

    uint256 balPrev = this.balance.sub(weiPaid);
    require(balPrev < MASTERY_THRESHOLD);

    pay(master, balPrev);

    MatchmasterTakeover(master, _addr, weiPaid); // called before new master set

    master = _addr; // must be set after event logged
  }

  // in case it ever needs to be updated for future Ethereum releases, etc
  function setGasReq(uint256 _gasReq) onlyOwner external {
    gasReq = _gasReq;
  }

  // initial funding
  function fund() onlyOwner external payable {
    require(now < startTime); // otherwise can just call mastery()

    // it is possible that funds can be forced in via selfdestruct, so
    // just ensure balance is enough, at least after receiving this call (msg.value)
    require(this.balance >= MASTERY_THRESHOLD);
  }

  // explicit balance getter
  function getBalance() external constant returns (uint256) {
    return this.balance;
  }

}

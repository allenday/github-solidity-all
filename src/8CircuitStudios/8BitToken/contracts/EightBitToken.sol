pragma solidity ^0.4.8;

import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract EightBitToken is StandardToken, Pausable {
  using SafeMath for uint256;

  string public constant name = '8 Circuit Studios Token';
  string public constant symbol = '8BT';
  uint256 public constant decimals = 18;

  uint256 public cap;
  uint256 public rate;
  uint256 public startBlock;
  uint256 public endBlock;
  uint256 public sold;

  event Sale(address indexed from, address indexed to, uint256 value, uint256 price);

  function EightBitToken() {
    totalSupply = 100 * (10**6) * 10**decimals;
    balances[owner] = totalSupply;
  }

  function () payable {
    buy(msg.sender);
  }

  function startSale(uint256 _cap, uint256 _rate, uint256 _startBlock, uint256 _endBlock) onlyOwner {
    require(cap == 0);
    require(_cap > 0);
    require(balances[owner] >= _cap);
    require(_rate > 0);
    require(block.number <= _startBlock);
    require(_endBlock >= _startBlock);

    cap = _cap;
    rate = _rate;
    startBlock = _startBlock;
    endBlock = _endBlock;
  }

  function buy(address _to) whenNotPaused payable {
    require(block.number >= startBlock && block.number <= endBlock);
    require(msg.value > 0);
    require(_to != 0x0);

    uint256 tokens = msg.value.mul(rate);

    sold = sold.add(tokens);
    assert(sold <= cap);

    balances[owner] = balances[owner].sub(tokens);
    balances[_to] = balances[_to].add(tokens);

    assert(owner.send(msg.value));

    Sale(owner, _to, tokens, msg.value);
  }

  function endSale() onlyOwner {
    cap = 0;
    rate = 0;
    startBlock = 0;
    endBlock = 0;
    sold = 0;
  }

  // ERC20 overrides
  function transfer(address _to, uint256 _value) whenNotPaused {
    super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) whenNotPaused {
    super.transferFrom(_from, _to, _value);
  }
}

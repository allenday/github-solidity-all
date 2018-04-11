pragma solidity ^0.4.11;

import "./Owned.sol";
import "./HumanStandardToken.sol";
import "./Locked.sol";

import './SafeMath.sol';

contract Sales is Owned {
  address public wallet;
  HumanStandardToken public token;
  Locked public locked;
  uint public price;
  uint public startBlock;
  uint public freezeBlock;
  bool public frozen = false;
  uint256 public cap = 0;
  uint256 public sold = 0;
  uint created;

  event PurchasedTokens(address indexed purchaser, uint amount);

  modifier saleHappening {
    require(block.number >= startBlock);
    require(block.number <= freezeBlock);
    require(!frozen);
    require(sold < cap);
    _;
  }

  function Sales(
    address _wallet,
    uint256 _tokenSupply,
    string _tokenName,
    uint8 _tokenDecimals,
    string _tokenSymbol,
    uint _price,
    uint _startBlock,
    uint _freezeBlock,
    uint256 _cap,
    uint _locked
  ) {
    wallet = _wallet;
    token = new HumanStandardToken(_tokenSupply, _tokenName, _tokenDecimals, _tokenSymbol);
    locked = new Locked(_locked);
    price = _price;
    startBlock = _startBlock;
    freezeBlock = _freezeBlock;
    cap = _cap;
    created = now;

    uint256 ownersValue = SafeMath.div(SafeMath.mul(token.totalSupply(), 20), 100);
    assert(token.transfer(wallet, ownersValue));

    uint256 saleValue = SafeMath.div(SafeMath.mul(token.totalSupply(), 60), 100);
    assert(token.transfer(this, saleValue));

    uint256 lockedValue = SafeMath.sub(token.totalSupply(), SafeMath.add(ownersValue, saleValue));
    assert(token.transfer(locked, lockedValue));
  }

  function purchaseTokens()
    payable
    saleHappening {
    uint excessAmount = msg.value % price;
    uint purchaseAmount = SafeMath.sub(msg.value, excessAmount);
    uint tokenPurchase = SafeMath.div(purchaseAmount, price);

    require(tokenPurchase <= token.balanceOf(this));

    if (excessAmount > 0) {
      msg.sender.transfer(excessAmount);
    }

    sold = SafeMath.add(sold, tokenPurchase);
    assert(sold <= cap);
    wallet.transfer(purchaseAmount);
    assert(token.transfer(msg.sender, tokenPurchase));
    PurchasedTokens(msg.sender, tokenPurchase);
  }

  /* owner only functions */
  function changeBlocks(uint _newStartBlock, uint _newFreezeBlock)
    onlyOwner {
    require(_newStartBlock != 0);
    require(_newFreezeBlock >= _newStartBlock);
    startBlock = _newStartBlock;
    freezeBlock = _newFreezeBlock;
  }

  function changePrice(uint _newPrice) 
    onlyOwner {
    require(_newPrice > 0);
    price = _newPrice;
  }

  function changeCap(uint256 _newCap)
    onlyOwner {
    require(_newCap > 0);
    cap = _newCap;
  }

  function unlockEscrow()
    onlyOwner {
    assert((now - created) > locked.period());
    assert(token.transfer(wallet, token.balanceOf(locked)));
  }

  function toggleFreeze()
    onlyOwner {
      frozen = !frozen;
  }
}

pragma solidity 0.4.11;

import "../satelites/PullPayment.sol";
import "./NutzEnabled.sol";
import "../satelites/Nutz.sol";

contract MarketEnabled is NutzEnabled {

  uint256 constant INFINITY = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

  // address of the pull payemnt satelite
  address public pullAddr;

  // the Token sale mechanism parameters:
  // purchasePrice is the number of NTZ received for purchase with 1 ETH
  uint256 internal purchasePrice;

  // floor is the number of NTZ needed, to receive 1 ETH in sell
  uint256 internal salePrice;

  function MarketEnabled(address _pullAddr, address _storageAddr, address _nutzAddr)
    NutzEnabled(_nutzAddr, _storageAddr) {
    pullAddr = _pullAddr;
  }


  function ceiling() constant returns (uint256) {
    return purchasePrice;
  }

  // returns either the salePrice, or if reserve does not suffice
  // for active supply, returns maxFloor
  function floor() constant returns (uint256) {
    if (nutzAddr.balance == 0) {
      return INFINITY;
    }
    uint256 maxFloor = activeSupply().mul(1000000).div(nutzAddr.balance); // 1,000,000 WEI, used as price factor
    // return max of maxFloor or salePrice
    return maxFloor >= salePrice ? maxFloor : salePrice;
  }

  function moveCeiling(uint256 _newPurchasePrice) public onlyAdmins {
    require(_newPurchasePrice <= salePrice);
    purchasePrice = _newPurchasePrice;
  }

  function moveFloor(uint256 _newSalePrice) public onlyAdmins {
    require(_newSalePrice >= purchasePrice);
    // moveFloor fails if the administrator tries to push the floor so low
    // that the sale mechanism is no longer able to buy back all tokens at
    // the floor price if those funds were to be withdrawn.
    if (_newSalePrice < INFINITY) {
      require(nutzAddr.balance >= activeSupply().mul(1000000).div(_newSalePrice)); // 1,000,000 WEI, used as price factor
    }
    salePrice = _newSalePrice;
  }

  function purchase(address _sender, uint256 _value, uint256 _price) public onlyNutz whenNotPaused returns (uint256) {
    // disable purchases if purchasePrice set to 0
    require(purchasePrice > 0);
    require(_price == purchasePrice);

    uint256 amountBabz = purchasePrice.mul(_value).div(1000000); // 1,000,000 WEI, used as price factor
    // avoid deposits that issue nothing
    // might happen with very high purchase price
    require(amountBabz > 0);

    // make sure power pool grows proportional to economy
    uint256 activeSup = activeSupply();
    uint256 powPool = powerPool();
    if (powPool > 0) {
      uint256 powerShare = powPool.mul(amountBabz).div(activeSup.add(burnPool()));
      _setPowerPool(powPool.add(powerShare));
    }
    _setActiveSupply(activeSup.add(amountBabz));
    _setBabzBalanceOf(_sender, babzBalanceOf(_sender).add(amountBabz));
    return amountBabz;
  }

  function sell(address _from, uint256 _price, uint256 _amountBabz) public onlyNutz whenNotPaused {
    uint256 effectiveFloor = floor();
    require(_amountBabz != 0);
    require(effectiveFloor != INFINITY);
    require(_price == effectiveFloor);

    uint256 amountWei = _amountBabz.mul(1000000).div(effectiveFloor);  // 1,000,000 WEI, used as price factor
    require(amountWei > 0);
    // make sure power pool shrinks proportional to economy
    uint256 powPool = powerPool();
    uint256 activeSup = activeSupply();
    if (powPool > 0) {
      uint256 powerShare = powPool.mul(_amountBabz).div(activeSup);
      _setPowerPool(powPool.sub(powerShare));
    }
    _setActiveSupply(activeSup.sub(_amountBabz));
    _setBabzBalanceOf(_from, babzBalanceOf(_from).sub(_amountBabz));
    Nutz(nutzAddr).asyncSend(pullAddr, _from, amountWei);
  }


  // withdraw excessive reserve - i.e. milestones
  function allocateEther(uint256 _amountWei, address _beneficiary) public onlyAdmins {
    require(_amountWei > 0);
    // allocateEther fails if allocating those funds would mean that the
    // sale mechanism is no longer able to buy back all tokens at the floor
    // price if those funds were to be withdrawn.
    require(nutzAddr.balance.sub(_amountWei) >= activeSupply().mul(1000000).div(salePrice)); // 1,000,000 WEI, used as price factor
    Nutz(nutzAddr).asyncSend(pullAddr, _beneficiary, _amountWei);
  }

}

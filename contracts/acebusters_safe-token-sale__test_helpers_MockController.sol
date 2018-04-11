pragma solidity ^0.4.11;

import "../../contracts/controller/Controller.sol";

contract MockController is Controller {

  function MockController(address _powerAddr, address _pullAddr, address _nutzAddr, address _storageAddr)
    Controller(_powerAddr, _pullAddr, _nutzAddr, _storageAddr) {
  }

  function inflateActiveSupply(uint256 _extraSupply) public {
    _setActiveSupply(activeSupply().add(_extraSupply));
  }

  function ethBalance() public returns (uint256) {
    return this.balance;
  }

}

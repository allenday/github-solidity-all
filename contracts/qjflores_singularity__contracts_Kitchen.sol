pragma solidity ^0.4.6;

import "./Provider.sol";

contract Kitchen is Provider {

  mapping (bytes32 => menuItem) public menu;

  struct menuItem{
    bytes32 name;
    uint256 price;
  }

  function Kitchen() Provider("SingularityKitchen", "SingularityKitchen contract") {
  }

  function addStaff(address _userAddress) {
    staffList[_userAddress] = staffUser({
      active:true,
      lastUpdated: now,
      payout: 0
      });
  }

  function addItemToMenu(bytes32 _name, uint256 _price){
    menu[_name] = menuItem({name: _name,price:_price});
  }

  function addItemToUserDebt(address _userAddress, bytes32 _name) {
    setDebt(menu[_name].price, _userAddress);
  }

  function updateItemPrice(bytes32 _name, uint256 _price) {
    menu[_name].price = _price;
  }
}
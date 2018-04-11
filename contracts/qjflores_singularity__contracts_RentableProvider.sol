pragma solidity ^0.4.6;

import "./Provider.sol";

contract RentableProvider is Provider {

  mapping (bytes32 => RentableInfo) public rentables;

  struct RentableInfo {
    bool active;
    bytes32 name;
    uint256 dailyRate;
    uint256 weelyRate;
    uint256 montlyRate;
    uint256 quarterlyRate;
    address renter;
  }

  function RentableProvider(string _name, string _description) Provider("_name", "_description") {
    providerName = _name;
    description = _description;
  }

  function addRentable(bytes32 _name, uint256 _dailyRate, 
    uint256 _weelyRate, uint256 _montlyRate, uint256 _quarterlyRate) {
    rentables[_name] = RentableInfo({
      active:true,
      name:_name,
      dailyRate:_dailyRate,
      weelyRate: _weelyRate,
      montlyRate: _montlyRate,
      quarterlyRate: _quarterlyRate,
      renter: 0x0
      });
  }

  function changeDailyRate(bytes32 _name, uint256 _rate){
    rentables[_name].dailyRate = _rate;
  }

  function changeWeeklyRate(bytes32 _name, uint256 _rate){
    rentables[_name].weelyRate = _rate;
  }

  function changeMonthlyRate(bytes32 _name, uint256 _rate){
    rentables[_name].montlyRate = _rate;
  }

  function changeQuarterlyRate(bytes32 _name, uint256 _rate){
    rentables[_name].quarterlyRate = _rate;
  }

  function rentRentable(bytes32 _name, address _userAddress) {
    rentables[_name].renter = _userAddress;
  }

  function chargeDailyRate(bytes32 _name, address _userAddress){
    setDebt(rentables[_name].dailyRate, _userAddress);
  }

  function chargeWeeklyRate(bytes32 _name, address _userAddress){
    setDebt(rentables[_name].weelyRate, _userAddress);
  }

  function chargeMonthlyRate(bytes32 _name, address _userAddress){
    setDebt(rentables[_name].montlyRate, _userAddress);
  }

  function chargeQuarterlyRate(bytes32 _name, address _userAddress){
    setDebt(rentables[_name].quarterlyRate, _userAddress);
  }

}
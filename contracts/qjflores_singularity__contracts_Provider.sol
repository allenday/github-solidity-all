pragma solidity ^0.4.6;

import "./User.sol";

contract Provider {
  string public providerName;
  string public description;

  mapping (address => staffUser) public staffList;
  mapping (bytes32 => Job) public jobs;

  struct staffUser{
    bool active;
    uint lastUpdated;
    uint256 payout;
  }

  struct Job {
    bytes32 name;
    uint256 rate;
  }


  function Provider(string _name, string _description) {
    providerName = _name;
    description = _description;
  }


  function setDebt(uint256 _debt, address _userAddress) {
    User person = User(_userAddress);
    person.setDebt(_debt);
  }

  function recievePayment(address _userAddress) payable returns (bool result) {
    User person = User(_userAddress);
    person.clearDebt();
    return true;
  }

  function addStaff(address _userAddress) {
    staffList[_userAddress] = staffUser({
      active:true,
      lastUpdated: now,
      payout: 0
      });
  }

  function addJob(bytes32 _name, uint256 _rate) {
    jobs[_name] = Job({name:_name,rate:_rate});
  }

  function updateJobRate(bytes32 _name, uint256 _rate){
    jobs[_name].rate = _rate; 
  }

  function payOutJob(address _userAddress, bytes32 _jobName){
    staffList[_userAddress].payout += jobs[_jobName].rate;
  }

  function collectPayout(address _userContractAddress) {
    uint256 _amount = staffList[_userContractAddress].payout;
    staffList[_userContractAddress].payout = 0; 
    if(!_userContractAddress.send(_amount)){
      throw;
    }
  }

}
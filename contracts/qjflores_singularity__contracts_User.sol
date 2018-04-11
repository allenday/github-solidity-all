pragma solidity ^0.4.6;

contract User {
  string public userName;

  mapping (address => Service) public services;

  struct Service{
    bool active;
    uint lastUpdated;
    uint debt;
  }

  function User(string _name) payable {
    userName = _name;
  }

  function() payable {
  }

  function registerToProvider(address _providerAddress){
    services[_providerAddress] = Service({
      active:true,
      lastUpdated: now,
      debt: 0
      });
  }

  function setDebt(uint256 _debt){
    if(services[msg.sender].active){
      services[msg.sender].lastUpdated = now;
      services[msg.sender].debt += _debt;
      } else {
        throw;
      }
  }

  function clearDebt() returns (bool result){
    if (services[msg.sender].active){
      services[msg.sender].lastUpdated = now;
      services[msg.sender].debt = 0;
    } else {
      throw;
    }
  }

  function unsubcribe(address _providerAddress){
    if(services[_providerAddress].debt == 0){
      services[_providerAddress].active = false;
    } else {
      throw;
    }
  }

}
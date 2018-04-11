pragma solidity ^0.4.3;

library CreatorLib { //0xef5332db964cbd3e9433ca4217b439cd3af9c0bb

  event Registration(bytes32 ContentHash, string DistLicense);

  function RegisterIP(bytes32 _enterHash, string _distLicense){

    Registration (_enterHash, _distLicense);

  }

}

library createCreatorLib { //0x0bd6f2a7eef4cb8c7add809d044527d3b385bee4

  event CreatorCreated(address indexed etherAddress, address CreatorID);

  function newCreator(){
      CreatorCreated (msg.sender, new Creator());
  }

}

contract Mortal{
  address public Owner = tx.origin;
  modifier onlyOwner(){
    if(msg.sender == Owner){
      _;
    }else{throw;}
  }
  function kill() onlyOwner(){
    suicide(Owner);
  }
}

contract Creator is Mortal{

  address public Lib;

  event Registration(bytes32 ContentHash, string DistLicense);

  function changeLibAddress(address _LibAddress) onlyOwner(){
    Lib = _LibAddress;
  }

  function RegisterIP(bytes32 _enterHash, string _distLicense)  onlyOwner(){
    CreatorLib.RegisterIP(_enterHash, _distLicense);
  }

}

contract createCreator is Mortal{

  address public Lib;

  event CreatorCreated(address indexed etherAddress, address CreatorID);

  function changeLibAddress(address _LibAddress) onlyOwner(){
    Lib = _LibAddress;
  }

  function newCreator(){
    createCreatorLib.newCreator();
  }

}

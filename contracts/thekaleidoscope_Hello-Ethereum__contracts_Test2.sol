pragma solidity ^0.4.4;

contract Test2{
  address public owner;
  mapping (address=>uint)Wallet;
  mapping (address=>uint)Credits;
  uint Rate=20;
  function Test2(){
    owner=msg.sender;
  }

  modifier _Owner{
    if(msg.sender!=owner){
      throw ;
    }
    else {
      _;
    }
  }


 function giveCredits(address adr,uint crd) _Owner returns(bool State){
   Credits[adr]+=crd;
   return true;


 }


  function giveEther(address adr,uint amt ) _Owner returns (bool State){
    Wallet[adr]=amt;
    return true;
  }

  function buyCredits(address adr,uint crd) _Owner returns (bool res){

    if(Wallet[owner]<crd*Rate && Credits[adr]>crd ){
      return false;
    }

    Wallet[owner]-=crd*Rate;
    Credits[owner]+=crd;
    Wallet[adr]+=crd*Rate;
    Credits[adr]-=crd;
  }

  function Balance(address adr) constant returns (uint amt,uint crd){
    return (Wallet[adr],Credits[adr]);
  }



}

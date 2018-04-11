pragma solidity ^0.4.4;

contract Test1{
  address public owner ;
  uint ExRate=25;

  mapping(address=>uint) Wallet;
  mapping(address=>uint) Property;

//Init Config
  function Test1(){
    owner= msg.sender;
    Wallet[owner] = 1000;
    Property[owner]=0;
  }

  // Send Some Property
  function sendP(address ad , uint P)returns(bool St){
    Property[ad]=P;
return true;
  }
//Transfer function

  function makeTrans(address usr,uint amt) returns (bool State) {

    if((amt/ExRate)<=0){
      return false;
    }

  uint  Ar=amt/ExRate;
    Wallet[owner]-=amt;
    Wallet[usr]+=amt;

    Property[owner]+=Ar;
    Property[usr]-=Ar;

    return true;
  }

  //Check Balance
function balance(address usr) constant returns (uint bal,uint ar){
  return (Wallet[usr],Property[usr]);
}



/*  function transfer(address to,uint amt) returns (bool State){

    if(amt>Wallet[owner]){
      return false;
    }

    Wallet[owner] -= amt;
    Cars[owner]+= 1;
    Wallet[to] += amt;
    Cars[to]-= 1;
    return true;

  }
*/

}

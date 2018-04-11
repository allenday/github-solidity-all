/*
#  Copyright for Sergey Ponomarev (JackBekket)
#
#  This contracts allow you to automatically register contract you create.
#  And probably (to the moment of reading this will be implemented) signed it (verify)
#
#   This version worked without DAO inplementation
#
#
#
#   This version suuport multiply Notariuses
#
*/
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract Registrator  is owned{



string public standard = 'registrator 0.0.2';
string public version = '0.0.1';
string public t = 'noncommercial';

//address public notarius = owner;
//uint public price;

//  mapping (address => mapping (uint => string)) public Links;
// mapping (address => uint256) public balanceOf;

// Array of Owner - Contract - Signed by???
mapping (address => address) public Links;
mapping (address => mapping (address => address)) public Certs;
mapping (address => bool) public Notariuses;


event Registred(address _contract,string name, address client);
event Signed(address client, address _contract, address signedby);

//initialization
function Registrator (){
//price = pricePlace;
// address public notarius = owner;
Notariuses[msg.sender] = true;
}

// Probably need to use msg.sender instead of address _contract. Test this feauture later
function register (address _contract,string contractname,address _owner){
/*
if (amount<price) throw;
balance0f[msg.sender]=amount;
address client= msg.sender;
Links[address]=link;
Registred(client,amount,link);
*/


Links[_contract]=_owner;
Registred(_contract,contractname,_owner);
}


function sign (address _owner,address _contract)  {
// address notarius = msg.sender;
if (Notariuses[msg.sender]!=true) throw;
address notarius = msg.sender;

Certs[_owner][_contract]=notarius;
 //uint date = now * 1 minutes;
Signed(_owner,_contract,notarius );

}

function setNotarius(address notarius){

  Notariuses[notarius]=true;
}

function unRegister (address _owner,string contractname,address _contract) onlyOwner {
  if (Notariuses[msg.sender]!=true) throw;
delete  Links[_contract];
}

//function unRegOwn (address _owner,string contractname,address _contract) onlyOwner{
//  if (Notariuses[msg.sender]!=true) throw;
//delete  Links[_owner];

//}

function unSign (address _owner,address _contract) onlyOwner {
if (Notariuses[msg.sender]!=true) throw;
delete Certs[_owner][_contract];
}


function lookupRegName (address _contract) returns(address) {
return Links[_contract];


}

function lookupSigName (address _owner, address _contract) returns(address) {
return Certs[_owner][_contract];



}

/*
function safeWithdrawal() onlyOwner {


       if (owner == msg.sender) {
   //      amountToPay=amountRaised;
           if (owner.send(amountRaised)) {

            //   FundTransfer(beneficiary, amountRaised, false);
             //  amountAll=amountAll+amountToPay
           //    amountToPay=0;

          //     amountRaised=0;
           } else {
               //If we fail to send the funds to beneficiary, unlock funders balance
             //  fundingGoalReached = false;
           }
       }
   }
*/



function () {
  throw;
}

function destroy (){
  if (msg.sender == owner) {
        suicide(owner); // send funds to organizer
      }
}

}

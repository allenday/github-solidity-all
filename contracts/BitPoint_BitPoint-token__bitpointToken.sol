

pragma solidity 0.4.11;

contract owned {
   address public owner;

   function owned() {
       owner = msg.sender;
   }

   modifier onlyOwner {
       if (msg.sender != owner) throw;
       _;
   }

   function transferOwnership(address newOwner) onlyOwner {
       owner = newOwner;
   }
}

contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

contract Bitpoint is owned,SafeMath
{
    string public constant symbol = "BPT";
    string public constant name = "Bitpoint Token";
    uint256 public totalSupply;
    //TODO wei to eur
    uint256   eurval = 4;
    uint256   profitForuser;
    uint256   profitForContract;
    uint256 ethertosend;
 
    
mapping (address => uint256) balances;
mapping (address => uint256) withdrawn;


event TokenMinted(address   _for, uint256 _value);
event Withdraws(address   from, uint256 _value);
event Transfer(address   to,address   from, uint256 _value);
event TokenBurned( uint256 _value);


    function () payable {
        uint amount = msg.value;
         //TODO  convert amount to EUR
        amount =  safeMul(amount,eurval);
        balances[msg.sender] = balances[msg.sender] + amount;
        totalSupply  =totalSupply + amount;
        TokenMinted(msg.sender,amount);
        
      
    }
   
    function balanceOf(address _owner) constant returns (uint256 balance) {
       return balances[_owner];
   }
   function withdrawnFrom(address _owner) constant returns (uint256 balance) {
       return withdrawn[_owner];
   }
   //return unix timestamp
//     function creationTime(address _owner) constant returns (uint256 createdOn) {
//        return balances[_owner].createdOn;
//    }
    
    function transfer(address _to, uint256 _value) returns (bool success) {
     
       if (balances[msg.sender] >= _value && _value > 0) {
           balances[msg.sender] -= _value;
           balances[_to] += _value;
           Transfer(msg.sender, _to, _value);
           return true;
       } else { return false; }
   }
  
  function getTotalSupply() constant returns (uint) // this doesn't have anything to do with the act of greeting
   {                                                    
       return totalSupply;
   }

//AtM calls withdraw, to is address of customer to which ether to be send
function withdraw (uint256 value, address from, address to) onlyOwner {
   // withdraw will 
   if (balances[from] < value){
       return;
   }
   profitForuser = value * 4/100;
   profitForContract = value * 1/100;
   value = value - profitForuser;
   value = value - profitForContract;
   totalSupply = totalSupply + profitForContract;
   balances[from] = balances[from] - value;
   withdrawn[from] = withdrawn[from] + value;
   Withdraws(from,value);
   balances[from] = balances[from] + profitForuser;
      //send ether to address
  ethertosend =  value/eurval;
  to.transfer(ethertosend);
}

//ATM deposit ether back to contract
function deposit (uint256 value, address to)onlyOwner payable{
    uint amount = value;
         //TODO  convert amount to EUR
        amount =   amount * eurval;
        balances[to] = balances[to] + amount;
        totalSupply   = totalSupply+amount;
        withdrawn[to] = withdrawn[to] - amount;
        TokenMinted(to,amount);
}


 function kill()
   {
       if (msg.sender == owner)
           suicide(owner);  // kills this contract and sends remaining funds back to creator
   }

 
 
    

}

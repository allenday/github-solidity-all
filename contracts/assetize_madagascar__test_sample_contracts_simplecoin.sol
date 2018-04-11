contract SimpleCoin{
  mapping (address => uint32) balance;
  address owner;

  function SimpleCoin(){
    owner = msg.sender;
  }

  function issue(address recipient, uint32 amount){
    if(msg.sender == owner){
      balance[recipient] += amount;
    }
  }

  function balanceOf(address holder) returns (uint b){
    return balance[holder];
  }

  function transferTo(address recipient, uint32 amount){
    if(balance[msg.sender] < amount) return;

    balance[msg.sender] -= amount;
    balance[recipient] += amount;
  }
}

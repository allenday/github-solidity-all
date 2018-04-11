//会议门票合约例子 2016-3-1
contract Conference {
  address public organizer; //组织者
  mapping (address => uint) public registrantsPaid;
  uint public numRegistrants; //已买票人数
  uint public quota; //人数上限

  event Deposit(address _from, uint _amount);  
  event Refund(address _to, uint _amount); 

  function Conference() {
    organizer = msg.sender;
    quota = 500;
    numRegistrants = 0;
  }
  
  //买票，交易附加的eth的做为票价,自动存放在合约地址上
  function buyTicket() public returns (bool success) {
    if (numRegistrants >= quota) { return false; }
    registrantsPaid[msg.sender] = msg.value;
    numRegistrants++;
    Deposit(msg.sender, msg.value); //触发事件，eth存入
    return true;
  }
  
  function changeQuota(uint newquota) public {
    if (msg.sender != organizer) { return; }
    quota = newquota;
  }
  
  //组织者发起交易，给指定地址退款
  function refundTicket(address recipient, uint amount) public {
    if (msg.sender != organizer) { return; } //只允许组织者调用本函数
    
    if (registrantsPaid[recipient] == amount) { 
      address myAddress = this;
      if (myAddress.balance >= amount) { 
        recipient.send(amount);  //系统函数，向地址recipient发送eth
        registrantsPaid[recipient] = 0;
        numRegistrants--;
        Refund(recipient, amount); //触发事件，退款
      }
    }
  }
  
  
  function destroy() { // so funds not locked in contract forever
    if (msg.sender == organizer) { 
      suicide(organizer); //系统函数，合约中止将eth退给 organizer
    }
  }
}

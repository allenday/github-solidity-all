contract ClientReceipt is owned {
  event AnonymousDeposit(address indexed _from, uint _value);
  event Deposit(address indexed _from, uint _id, uint _value);
  event Refill(address indexed _from, uint _value);
  event Withdraw(address indexed _from, address indexed _to, uint _value);
  event Drain(address indexed _from, address indexed _to, uint _value);
  function() {
    AnonymousDeposit(msg.sender, msg.value);
  }
  function deposit(uint _id) {
    Deposit(msg.sender, _id, msg.value);
  }
  function refill() {
    Refill(msg.sender, msg.value);
  }
  function withdraw(address _to, uint _value) onlyowner {
    _to.send(_value);
    Withdraw(msg.sender, _to, _value);
  }
  function drain(address _to, uint _value) onlyowner {
    _to.send(_value);
    Drain(msg.sender, _to, _value);
  }
}
import "owned";


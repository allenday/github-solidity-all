pragma solidity ^0.4.4;
import "../contracts/BiathlonToken.sol";
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

/* Attempt to make something upgradeable */

contract TokenStorage is Ownable, StandardToken {
  address node;


  function TokenStorage(address _node) public {
    node = _node;
  }


  modifier onlyOwner() {
    require(msg.sender == owner || msg.sender == node);
    _;
  }

 /*
  function alterTotalSupply(uint256 _amount) onlyOwner public returns (bool) {
    totalSupply = _amount;
    return true;
  }
  */

  function subtract(address _addr, uint256 _amount) onlyOwner external returns (bool) {
    require(_amount > 0);
    require(_amount <= balances[_addr]);
    balances[_addr] -= _amount;
    totalSupply_ = totalSupply_.sub(_amount);
    return true;
  }

  function add(address _addr, uint256 _amount) onlyOwner external returns (bool) {
    balances[_addr] = balances[_addr].add(_amount);
    totalSupply_ = totalSupply_.add(_amount);
    return true;
  }

  /* override StandardToken function to remove allowances */
  function transferFrom(address _from, address _to, uint256 _value) onlyOwner public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(_from, _to, _value);
    return true;
  }

}

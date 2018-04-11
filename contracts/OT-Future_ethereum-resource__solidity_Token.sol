progma solidity ^0.4.17;

contract Token{
  mapping(address => uint256) public balanceOf;

  function Token(){
    balanceOf[msg.sender] = 1000000000000;
  }

  function transfer(address _to, uint256 _value) constance public{
    address _from = msg.sender;
    require(balanceOf[_from] >= _value);
    require(balanceOf[_to] + _value >= balanceOf[_to]);

    uint256 totalBalance = balanceOf[_from] + balanceOf[_to];
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;

    assert(totalBalance == balanceOf[_from] + balanceOf[_to]);
  }
}
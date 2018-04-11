pragma solidity ^0.4.14;
// 
// mapping http://solidity.readthedocs.io/en/develop/types.html#mappings
// 
contract Foo {

    // Mappings are only allowed for state variables (or as storage reference types in internal functions).
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) allowed;

    function Foo(){
       balances[msg.sender] = 1000 ether;
    }

    function update(uint newBalance) {
        balances[msg.sender] = newBalance;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}

contract FooUser {
    function testFooUdate(uint amount) returns (uint) {
        Foo foo = new Foo();
        foo.update(amount);
        // msg.sender is the contract address
        return foo.balances(this);
    }

    function testFooApprove(uint amount) returns (uint) {
        Foo foo = new Foo();
        foo.update(amount);
        foo.approve(address(0xdead), amount/2);
        return foo.allowance(this,address(0xdead));
    }
}
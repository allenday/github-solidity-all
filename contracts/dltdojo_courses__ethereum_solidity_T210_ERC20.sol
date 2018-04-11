/*
Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
https://github.com/ConsenSys/Tokens/blob/master/contracts/StandardToken.sol
*/
pragma solidity ^0.4.8;

contract Token {
    
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}


contract FooToken is StandardToken {
    function FooToken(){
        totalSupply = 2100 ether;
        balances[msg.sender] = totalSupply;
    }
}

contract User {
    function transferFrom(FooToken ft, address _from, address _to, uint256 _value){
        ft.transferFrom(_from, _to, _value);
    }
}

contract FooTokenTest {
    
    function testTransfer() {
        User alice = new User();
        User bob = new User();
        FooToken ft = new FooToken();
        ft.transfer(alice,10 ether);
        require(ft.balanceOf(alice)== 10 ether);
        ft.transfer(bob, 20 ether);
        require(ft.balanceOf(bob)== 20 ether);
    }
    
    function testTransferFrom() {
        User alice = new User();
        User bob = new User();
        FooToken ft = new FooToken();
        require(ft.balanceOf(this)== 2100 ether);
        
        // approve by FooTokenTest
        require(ft.approve(alice, 5 ether));
        
        require(ft.allowance(this, alice) == 5 ether);
        alice.transferFrom(ft,  this, bob, 2 ether);
        require(ft.allowance(this, alice) == 3 ether);
        require(ft.balanceOf(alice)== 0 ether);
        require(ft.balanceOf(bob)== 2 ether);
    }
}


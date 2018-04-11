pragma solidity ^0.4.15;


import "./StantardTokenInterface.sol";
import "./OLCommonConfigure.sol";

contract StandardToken is StantardTokenInterface,OLCommonConfigure{

    uint256 constant MAX_UINT256 = 2 * 256 - 1;

    function transfer(address _to, uint256 _value) returns (uint) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        if(balances[msg.sender] < _value){
            return errorCode_cannotTransMoreThanYouHave;
        }
        if(balances[_to] + _value < balances[_to]){
            return errorCode_cannotTransNegativeValue;
        }

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return errorCode_success;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (uint) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        if(balances[_from] < _value){
            return errorCode_cannotTransMoreThanYouHave;
        }

        if(allowed[_from][_to] < _value){
            return errorCode_allowedValueIsNotEnough;
        }

        if(balances[_to] + _value > balances[_to]){
            return errorCode_cannotTransNegativeValue;
        }


        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][_to] -= _value;
        Transfer(_from, _to, _value);

        return errorCode_success;
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

    function chargeFee(address _spender, address _marketChargeManager, uint _value) public returns(uint){
        uint code = transfer(_spender, _value);
        if(code != errorCode_success){
            return code;
        }

        allowed[_spender][_marketChargeManager] += _value;
        return errorCode_success;
    }

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;
}
pragma solidity ^0.4.18;

import '../node_modules/zeppelin-solidity/contracts/token/StandardToken.sol';

contract MugenMoney is StandardToken {

    // token information
    string public constant NAME = "Mugen Money";
    string public constant SYMBOL = "MGM";
    uint32 public constant DECIMALS = 18;

    event Mint(address indexed _receiver, uint _amount);

    function getMoney(address _receiver, uint _amount) public returns (uint newBalance) {
        require(_amount > 0);
        if (_receiver == 0x0) {
            _receiver = msg.sender;
        }
        
        totalSupply = totalSupply.add(_amount);
        balances[_receiver] = balances[_receiver].add(_amount);

        assert(balances[_receiver] > 0);
        Mint(_receiver, _amount);
        return balanceOf(_receiver);
    }

    // burn sender's all tokens
    function burnMoney() public returns (bool success) {
        uint balance = balanceOf(msg.sender);
        balances[msg.sender] = 0;
        totalSupply = totalSupply.sub(balance);
        return true;
    }
}

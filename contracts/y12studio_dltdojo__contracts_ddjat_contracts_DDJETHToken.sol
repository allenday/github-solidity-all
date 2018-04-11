pragma solidity ^0.4.10;

import 'zeppelin/contracts/token/MintableToken.sol';

contract DDJETHToken is MintableToken {
    string public name = "DLTDOJO Ether Token";
    string public symbol = "DDJETHT";
    uint public decimals = 18;
	function DDJETHToken() {
	}
    // BasicToken.sol
    // using SafeMath for uint;
    function deposit() external payable {
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        totalSupply = totalSupply.add(msg.value);
    }

    function withdraw(uint amount) external {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply = totalSupply.sub(amount);
        if (!msg.sender.send(amount)) {
            throw;
        }
    }

}

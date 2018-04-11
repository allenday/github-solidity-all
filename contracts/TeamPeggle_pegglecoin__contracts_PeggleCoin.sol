pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/PausableToken.sol';

contract BurnableToken is StandardToken {
    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

contract PeggleCoin is StandardToken, MintableToken, BurnableToken, PausableToken {
  string public constant name = "PeggleCoin";
  string public constant symbol = "PEGGLE";
  uint8 public constant decimals = 18;
  string public constant url = "http://teampeggle.com/";
  string public pegglebot = "<PeggleBot> initiate protocol for a hat wobble";

  uint256 public constant INITIAL_SUPPLY = 420 * (10 ** uint256(decimals));

  function PeggleCoin() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

  function setPeggleBot(string newPegglebot) onlyOwner {
    pegglebot = newPegglebot;
  }
}

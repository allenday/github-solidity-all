pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import './MultiOwnable.sol';


contract MintableToken is StandardToken, MultiOwnable {
    // Emitted when new coin is brought into the world
    event Mint(address indexed to, uint256 amount);

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) onlyOwner returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);

        return true;
    }
}

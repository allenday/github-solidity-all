pragma solidity ^0.4.11;

/*
    Initially from :  https://github.com/OpenZeppelin
    Changed by : Paris Jimmy

   The Minting is only allowed in the period Q1
   A part of the inital code became usless and been deleted
*/

import './CongressOwned.sol';

contract MintableToken is CongressOwned {

  event Mint(address indexed to, uint256 amount);

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyInQ1 onlyOwner onlyMembers(_to)  {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount); // Detail : 0x0 Because we create new tokens in the minting process (there is no sender of the transfer in term of loss)
  }
}

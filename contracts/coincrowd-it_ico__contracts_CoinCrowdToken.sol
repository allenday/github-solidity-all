pragma solidity ^0.4.15;

import "zeppelin/contracts/token/BurnableToken.sol";
import "./Constants.sol";

contract CoinCrowdToken is BurnableToken, Constants {
    string public name = "CoinCrowd";

    string public symbol = "XCC";

    uint256 public totalSupply = 100000000 * 10 ** uint(decimals);  // 100 millions XCC

    uint256 public initialSupply = totalSupply;

    function CoinCrowdToken() {
        balances[msg.sender] = totalSupply;
    }
}

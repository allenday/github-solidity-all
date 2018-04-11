pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/token/MintableToken.sol";

contract UTCoin is MintableToken {
    string public constant name = "UTCoin";
    string public constant symbol = "UTC";
    uint256 public constant decimals = 3;

    uint256 public constant initialSupply = 100000000 * (10 ** uint256(decimals)); // 100,000,000 UTC

    function UTCoin() public {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;
    }
}

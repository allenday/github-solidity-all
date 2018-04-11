pragma solidity ^0.4.15;

import "./Owned.sol";
import "./ERC20.sol";

contract TokenIceBox is Owned {
    ERC20 public token;

    function TokenIceBox(address token_){
     token = ERC20(token_);
    }

    function transfer (address dst, uint wad) onlyOwner {
        token.transfer(dst, wad);
    }
}

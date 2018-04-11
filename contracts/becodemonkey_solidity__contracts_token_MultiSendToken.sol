pragma solidity ^0.4.18;


import '../util/Ownable.sol';
import './ERC20.sol';

// @title MultiSendToken - Allows sending of tokens to multiple addresses with single call saving gas
// @author Philip
// @version 0.1
contract MultiSendToken is Ownable {

    // Token Address I would recommend you hard code this
    address public tokenAddress;

    /**********************
    * Functions
    ***********************/

    function MultiSendToken() public {
        require(tokenAddress != 0x0);
    }

    function multisend(address[] _dests, uint256[] _values) public onlyOwner returns (uint256) {
        uint256 i = 0;
        while (i < _dests.length) {
            ERC20(tokenAddress).transfer(_dests[i], _values[i]);
            i += 1;
        }
        return (i);
    }
}

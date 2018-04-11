pragma solidity ^0.4.15;

import '../../contracts/UnityToken.sol';


contract MockToken is UnityToken {
    function MockToken(uint256 _totalSupply) UnityToken(_totalSupply){}

    function isAllowedOverrideAddress(address _addr) external constant returns (bool) {
        return allowedOverrideAddresses[_addr];
    }
}

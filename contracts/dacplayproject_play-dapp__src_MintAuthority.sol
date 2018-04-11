pragma solidity ^0.4.13;

import "ds-token/token.sol";

// For removing this authority, set by using setAuthority(DSAuthority(0));
contract MintAuthority is DSAuthority {
    address public miner;

    function MintAuthority(address _miner)
    {
        miner = _miner;
    }

    function canCall(
        address _src, address _dst, bytes4 _sig
    ) constant returns (bool) {
        return ( _src == miner && _sig == bytes4(keccak256("mint(address,uint256)")) );
    }
}
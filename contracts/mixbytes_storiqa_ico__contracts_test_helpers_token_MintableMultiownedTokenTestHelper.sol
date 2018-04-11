pragma solidity 0.4.15;

import '../../token/MintableMultiownedToken.sol';


/// @title Test helper for MintableMultiownedToken, DONT use it in production!
contract MintableMultiownedTokenTestHelper is MintableMultiownedToken {

    function MintableMultiownedTokenTestHelper(address[] _owners, uint _signatures, address _minter)
        MintableMultiownedToken(_owners, _signatures, _minter)
    {
    }

    function emission(uint256 _weiToEmit) external onlymanyowners(sha3(msg.data)) {
        emissionInternal(_weiToEmit);
    }
}

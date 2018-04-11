pragma solidity 0.4.15;

import '../../crowdsale/FundsRegistry.sol';


/// @title DONT use it in production! Its a test helper which can burn money.
contract FundsRegistryTestHelper is FundsRegistry {

    function FundsRegistryTestHelper(address[] _owners, uint _signaturesRequired, address _controller)
        FundsRegistry(_owners, _signaturesRequired, _controller)
    {
    }

    function burnSomeEther() external onlyowner {
        address(0).transfer(10 finney);
    }
}

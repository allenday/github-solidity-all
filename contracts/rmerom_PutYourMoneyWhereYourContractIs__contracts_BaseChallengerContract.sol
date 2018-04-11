pragma solidity ^0.4.4;

import "./EnvironmentContractInterface.sol";

contract BaseChallengerContract {
    function execute(address targetContract, EnvironmentContractInterface env);
}


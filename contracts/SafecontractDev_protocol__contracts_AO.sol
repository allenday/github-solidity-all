pragma solidity ^0.4.15;
import './Backdoor.sol';
import './interfaces/IRewardDAO.sol';
import './bancor_contracts/SmartToken.sol';

/**
    The SafeToken (AO) is our implementation of the Smart Token with
    the addition of the ERC23 token fallback function employed.
 */
contract AO is SmartToken, Backdoor {
    IRewardDAO rewardDAO;

    function AO()
        SmartToken("SafeToken", "AO", 18)
    {}
}
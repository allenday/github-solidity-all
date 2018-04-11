pragma solidity 0.4.15;

import './STQPreICOBase.sol';
import './crowdsale/ExternalAccountWalletConnector.sol';


/// @title Storiqa pre-ICO contract
contract STQPreICO3 is STQPreICOBase, ExternalAccountWalletConnector {

    function STQPreICO3(address token, address wallet)
        STQPreICOBase(token)
        ExternalAccountWalletConnector(wallet)
    {

    }


    // INTERNAL

    function getWeiCollected() public constant returns (uint) {
        return getTotalInvestmentsStored();
    }

    /// @notice minimum amount of funding to consider crowdsale as successful
    function getMinimumFunds() internal constant returns (uint) {
        return 0;
    }

    /// @notice maximum investments to be accepted during pre-ICO
    function getMaximumFunds() internal constant returns (uint) {
        return 100000000 ether;
    }

    /// @notice start time of the pre-ICO
    function getStartTime() internal constant returns (uint) {
        return 1508958000; // 2017-10-25 19:00:00
    }

    /// @notice end time of the pre-ICO
    function getEndTime() internal constant returns (uint) {
        return 1511568000; //2017-11-25 00:00:00
    }

    /// @notice pre-ICO bonus
    function getPreICOBonus() internal constant returns (uint) {
        return 33;
    }
}

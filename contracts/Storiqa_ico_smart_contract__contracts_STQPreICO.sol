pragma solidity 0.4.15;

import './STQPreICOBase.sol';
import './crowdsale/ExternalAccountWalletConnector.sol';


/// @title Storiqa pre-ICO contract
contract STQPreICO is STQPreICOBase, ExternalAccountWalletConnector {

    function STQPreICO(address token, address funds)
        STQPreICOBase(token)
        ExternalAccountWalletConnector(funds)
    {
    }


    // INTERNAL

    /// @notice minimum amount of funding to consider crowdsale as successful
    function getMinimumFunds() internal constant returns (uint) {
        return 0;
    }

    /// @notice maximum investments to be accepted during pre-ICO
    function getMaximumFunds() internal constant returns (uint) {
        return 3500 ether;
    }

    /// @notice start time of the pre-ICO
    function getStartTime() internal constant returns (uint) {
        return 1507766400;
    }

    /// @notice end time of the pre-ICO
    function getEndTime() internal constant returns (uint) {
        return getStartTime() + (1 days);
    }

    /// @notice pre-ICO bonus
    function getPreICOBonus() internal constant returns (uint) {
        return 40;
    }
}

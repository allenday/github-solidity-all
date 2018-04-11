pragma solidity 0.4.15;

import './STQPreICOBase.sol';
import './crowdsale/FundsRegistryWalletConnector.sol';


/// @title Storiqa pre-ICO contract
contract STQPreICO2 is STQPreICOBase, FundsRegistryWalletConnector {

    function STQPreICO2(address token, address[] fundOwners)
        STQPreICOBase(token)
        FundsRegistryWalletConnector(fundOwners, 2)
    {
        require(3 == fundOwners.length);
    }


    // INTERNAL

    function getWeiCollected() public constant returns (uint) {
        return getTotalInvestmentsStored().add(2401 ether /* previous crowdsales */);
    }

    /// @notice minimum amount of funding to consider crowdsale as successful
    function getMinimumFunds() internal constant returns (uint) {
        return 3500 ether;
    }

    /// @notice maximum investments to be accepted during pre-ICO
    function getMaximumFunds() internal constant returns (uint) {
        return 8500 ether;
    }

    /// @notice start time of the pre-ICO
    function getStartTime() internal constant returns (uint) {
        return 1508346000;
    }

    /// @notice end time of the pre-ICO
    function getEndTime() internal constant returns (uint) {
        return getStartTime() + (5 days);
    }

    /// @notice pre-ICO bonus
    function getPreICOBonus() internal constant returns (uint) {
        return 35;
    }
}

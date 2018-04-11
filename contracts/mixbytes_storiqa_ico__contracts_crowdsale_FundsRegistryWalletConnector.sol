pragma solidity 0.4.15;

import './IInvestmentsWalletConnector.sol';
import './FundsRegistry.sol';


/**
 * @title Stores investments in FundsRegistry.
 * @author Eenae
 */
contract FundsRegistryWalletConnector is IInvestmentsWalletConnector {

    function FundsRegistryWalletConnector(address[] fundOwners, uint ownersSignatures)
    {
        m_fundsAddress = new FundsRegistry(fundOwners, ownersSignatures, this);
    }

    /// @dev process and forward investment
    function storeInvestment(address investor, uint payment) internal
    {
        m_fundsAddress.invested.value(payment)(investor);
    }

    /// @dev total investments amount stored using storeInvestment()
    function getTotalInvestmentsStored() internal constant returns (uint)
    {
        return m_fundsAddress.totalInvested();
    }

    /// @dev called in case crowdsale succeeded
    function wcOnCrowdsaleSuccess() internal {
        m_fundsAddress.changeState(FundsRegistry.State.SUCCEEDED);
        m_fundsAddress.detachController();
    }

    /// @dev called in case crowdsale failed
    function wcOnCrowdsaleFailure() internal {
        m_fundsAddress.changeState(FundsRegistry.State.REFUNDING);
        m_fundsAddress.detachController();
    }

    /// @notice address of wallet which stores funds
    FundsRegistry public m_fundsAddress;
}

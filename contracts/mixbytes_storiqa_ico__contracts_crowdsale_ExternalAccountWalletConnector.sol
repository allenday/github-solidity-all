pragma solidity 0.4.15;

import './IInvestmentsWalletConnector.sol';
import '../security/ArgumentsChecker.sol';


/**
 * @title Stores investments in specified external account.
 * @author Eenae
 */
contract ExternalAccountWalletConnector is ArgumentsChecker, IInvestmentsWalletConnector {

    function ExternalAccountWalletConnector(address accountAddress)
        validAddress(accountAddress)
    {
        m_walletAddress = accountAddress;
    }

    /// @dev process and forward investment
    function storeInvestment(address /*investor*/, uint payment) internal
    {
        m_wcStored += payment;
        m_walletAddress.transfer(payment);
    }

    /// @dev total investments amount stored using storeInvestment()
    function getTotalInvestmentsStored() internal constant returns (uint)
    {
        return m_wcStored;
    }

    /// @dev called in case crowdsale succeeded
    function wcOnCrowdsaleSuccess() internal {
    }

    /// @dev called in case crowdsale failed
    function wcOnCrowdsaleFailure() internal {
    }

    /// @notice address of wallet which stores funds
    address public m_walletAddress;

    /// @notice total investments stored to wallet
    uint public m_wcStored;
}

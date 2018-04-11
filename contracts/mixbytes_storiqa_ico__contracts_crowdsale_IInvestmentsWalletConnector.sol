pragma solidity 0.4.15;

/**
 * @title Interface for code which processes and stores investments.
 * @author Eenae
 */
contract IInvestmentsWalletConnector {
    /// @dev process and forward investment
    function storeInvestment(address investor, uint payment) internal;

    /// @dev total investments amount stored using storeInvestment()
    function getTotalInvestmentsStored() internal constant returns (uint);

    /// @dev called in case crowdsale succeeded
    function wcOnCrowdsaleSuccess() internal;

    /// @dev called in case crowdsale failed
    function wcOnCrowdsaleFailure() internal;
}

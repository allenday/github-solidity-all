pragma solidity 0.4.15;

import './crowdsale/SimpleCrowdsaleBase.sol';
import './crowdsale/InvestmentAnalytics.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


/// @title Base contract for Storiqa pre-ICO
contract STQPreICOBase is SimpleCrowdsaleBase, Ownable, InvestmentAnalytics {

    function STQPreICOBase(address token)
        SimpleCrowdsaleBase(token)
    {
    }


    // PUBLIC interface: maintenance

    function createMorePaymentChannels(uint limit) external onlyOwner returns (uint) {
        return createMorePaymentChannelsInternal(limit);
    }

    /// @notice Tests ownership of the current caller.
    /// @return true if it's an owner
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to
    // addOwner/changeOwner and to isOwner.
    function amIOwner() external constant onlyOwner returns (bool) {
        return true;
    }


    // INTERNAL

    /// @dev payment callback
    function iaOnInvested(address investor, uint payment, bool usingPaymentChannel) internal {
        buyInternal(investor, payment, usingPaymentChannel ? c_paymentChannelBonusPercent : 0);
    }

    function calculateTokens(address /*investor*/, uint payment, uint extraBonuses) internal constant returns (uint) {
        uint bonusPercent = getPreICOBonus().add(getLargePaymentBonus(payment)).add(extraBonuses);
        uint rate = c_STQperETH.mul(bonusPercent.add(100)).div(100);

        return payment.mul(rate);
    }

    function getLargePaymentBonus(uint payment) private constant returns (uint) {
        if (payment >= 5000 ether) return 20;
        if (payment >= 3000 ether) return 15;
        if (payment >= 1000 ether) return 10;
        if (payment >= 800 ether) return 8;
        if (payment >= 500 ether) return 5;
        if (payment >= 200 ether) return 2;
        return 0;
    }

    function mustApplyTimeCheck(address investor, uint /*payment*/) constant internal returns (bool) {
        return investor != owner;
    }

    /// @notice pre-ICO bonus
    function getPreICOBonus() internal constant returns (uint);


    // FIELDS

    /// @notice starting exchange rate of STQ
    uint public constant c_STQperETH = 100000;

    /// @notice authorised payment bonus
    uint public constant c_paymentChannelBonusPercent = 2;
}

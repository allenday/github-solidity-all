pragma solidity 0.4.15;

import '../../crowdsale/InvestmentAnalytics.sol';


contract InvestmentAnalyticsTestHelper is InvestmentAnalytics {
    function createMorePaymentChannels(uint limit) external returns (uint) {
        return createMorePaymentChannelsInternal(limit);
    }
}

pragma solidity 0.4.15;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';


/*
 * @title This is proxy for analytics. Target contract can be found at field m_analytics (see "read contract").
 * @author Eenae

 * FIXME after fix of truffle issue #560: refactor to a separate contract file which uses InvestmentAnalytics interface
 */
contract AnalyticProxy {

    function AnalyticProxy() {
        m_analytics = InvestmentAnalytics(msg.sender);
    }

    /// @notice forward payment to analytics-capable contract
    function() payable {
        m_analytics.iaInvestedBy.value(msg.value)(msg.sender);
    }

    InvestmentAnalytics public m_analytics;
}


/*
 * @title Mixin contract which supports different payment channels and provides analytical per-channel data.
 * @author Eenae
 */
contract InvestmentAnalytics {
    using SafeMath for uint256;

    function InvestmentAnalytics(){
    }

    /// @dev creates more payment channels, up to the limit but not exceeding gas stipend
    function createMorePaymentChannelsInternal(uint limit) internal returns (uint) {
        uint paymentChannelsCreated;
        for (uint i = 0; i < limit; i++) {
            uint startingGas = msg.gas;
            /*
             * ~170k of gas per paymentChannel,
             * using gas price = 4Gwei 2k paymentChannels will cost ~1.4 ETH.
             */

            address paymentChannel = new AnalyticProxy();
            m_validPaymentChannels[paymentChannel] = true;
            m_paymentChannels.push(paymentChannel);
            paymentChannelsCreated++;

            // cost of creating one channel
            uint gasPerChannel = startingGas.sub(msg.gas);
            if (gasPerChannel.add(50000) > msg.gas)
                break;  // enough proxies for this call
        }
        return paymentChannelsCreated;
    }


    /// @dev process payments - record analytics and pass control to iaOnInvested callback
    function iaInvestedBy(address investor) external payable {
        address paymentChannel = msg.sender;
        if (m_validPaymentChannels[paymentChannel]) {
            // payment received by one of our channels
            uint value = msg.value;
            m_investmentsByPaymentChannel[paymentChannel] = m_investmentsByPaymentChannel[paymentChannel].add(value);
            // We know for sure that investment came from specified investor (see AnalyticProxy).
            iaOnInvested(investor, value, true);
        } else {
            // Looks like some user has paid to this method, this payment is not included in the analytics,
            // but, of course, processed.
            iaOnInvested(msg.sender, msg.value, false);
        }
    }

    /// @dev callback
    function iaOnInvested(address /*investor*/, uint /*payment*/, bool /*usingPaymentChannel*/) internal {
    }


    function paymentChannelsCount() external constant returns (uint) {
        return m_paymentChannels.length;
    }

    function readAnalyticsMap() external constant returns (address[], uint[]) {
        address[] memory keys = new address[](m_paymentChannels.length);
        uint[] memory values = new uint[](m_paymentChannels.length);

        for (uint i = 0; i < m_paymentChannels.length; i++) {
            address key = m_paymentChannels[i];
            keys[i] = key;
            values[i] = m_investmentsByPaymentChannel[key];
        }

        return (keys, values);
    }

    function readPaymentChannels() external constant returns (address[]) {
        return m_paymentChannels;
    }


    mapping(address => uint256) public m_investmentsByPaymentChannel;
    mapping(address => bool) m_validPaymentChannels;

    address[] public m_paymentChannels;
}

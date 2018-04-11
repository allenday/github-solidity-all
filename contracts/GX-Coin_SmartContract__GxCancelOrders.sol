pragma solidity ^0.4.2;

import './GxEditable.sol';
import './GxCallableByDeploymentAdmin.sol';
import './GxCallableByTrader.sol';
import './GxCallableByAdmin.sol';
import './GxRaisesEvents.sol';
import './GxUsesOrders.sol';
import './GxUsesTradersProxy.sol';

contract GxCancelOrders is GxCallableByDeploymentAdmin, GxEditable, GxRaisesEvents, GxUsesOrders, GxUsesTradersProxy, GxCallableByTrader, GxCallableByAdmin {
    function GxCancelOrders(address deploymentAdminsAddress) GxCallableByDeploymentAdmin(deploymentAdminsAddress) {
        isEditable = true;
    }

    function cancelOrder(uint80 orderId, bool isBuy) public callableByTrader {
        cancelOrderInternal(orderId, isBuy, false);
    }

    function cancelOrderByAdmin(uint80 orderId, bool isBuy) public callableByAdmin {
        cancelOrderInternal(orderId, isBuy, true);
    }

    function cancelOrderInternal(uint80 orderId, bool isBuy, bool isAdmin) private {
        Order memory order = getOrder(isBuy ? buyOrders : sellOrders, orderId);

        if (order.orderId == 0) {
            return;
        }

        if (isAdmin || order.account == msg.sender) {
            if (isBuy) {
                removeBuyOrder(order);
            }
            else {
                removeSellOrder(order);
            }
        }
    }

    function removeSellOrder(Order order) private canUpdateSellOrders {
        uint32 coinBalance = traders.coinBalance(order.account) + order.quantity;
        tradersProxy.setCoinBalance(order.account, coinBalance);
        events.raiseSellOrderCancelled(
            order.account, 
            order.quantity, 
            order.pricePerCoin, 
            order.orderId,
            order.originalQuantity, 
            coinBalance, 
            traders.dollarBalance(order.account));

        sellOrders.remove(order.orderId);
    }

    function removeBuyOrder(Order order) private canUpdateBuyOrders {
        int160 dollarBalance = traders.dollarBalance(order.account) + (order.quantity * order.pricePerCoin);
        tradersProxy.setDollarBalance(order.account, dollarBalance);
        events.raiseBuyOrderCancelled(
            order.account, 
            order.quantity, 
            order.pricePerCoin, 
            order.orderId,
            order.originalQuantity, 
            traders.coinBalance(order.account), 
            dollarBalance);

        buyOrders.remove(order.orderId);
    }
}
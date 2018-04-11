pragma solidity ^0.4.2;

import './GxEditable.sol';
import './GxCallableByDeploymentAdmin.sol';
import './GxCallableByTrader.sol';
import './GxRaisesEvents.sol';
import './GxUsesOrders.sol';
import './GxUsesConstants.sol';
import './GxUsesTradersProxy.sol';

import './GxOrderList.sol';


contract GxOrders is GxCallableByDeploymentAdmin, GxEditable, GxUsesConstants, GxRaisesEvents, GxCallableByTrader, GxUsesOrders, GxUsesTradersProxy {
    function GxOrders(address deploymentAdminsAddress) GxCallableByDeploymentAdmin(deploymentAdminsAddress) {
        isEditable = true;
    }

    function createOrder(uint32 quantity, uint32 pricePerCoin, uint whenToExpire, bool isBuy) public callableWhenEditable callableByTrader {
        Order memory order = Order({
            orderId: 0,
            account: msg.sender,
            quantity: quantity,
            originalQuantity: quantity,
            pricePerCoin: pricePerCoin,
            expirationTime: whenToExpire,
            nextByPrice: 0,
            previousByPrice: 0
        });

        createAndMatchOrder(
            order,
            isBuy ? buyOrders : sellOrders,
            isBuy ? sellOrders : buyOrders,
            isBuy);
    }

    // combine the buy and sell logic to reduce the contract size
    function createAndMatchOrder(Order order, GxOrderList orderList, GxOrderList matchOrderList, bool isBuy) private canUpdateSellOrders canUpdateBuyOrders {
        if (order.quantity == 0 || order.pricePerCoin == 0) {
            return;
        }

        int160 dollarBalance = traders.dollarBalance(order.account);
        uint32 coinBalance = traders.coinBalance(order.account);

        if (isBuy) {
            if (dollarBalance < order.quantity * order.pricePerCoin) {
                return;
            }
            dollarBalance -= order.quantity * order.pricePerCoin;
            tradersProxy.setDollarBalance(order.account, dollarBalance);
        } else {
            if (coinBalance < order.quantity) {
                return;
            }
            coinBalance -= order.quantity;
            tradersProxy.setCoinBalance(order.account, coinBalance);
        }

        order.orderId = orderList.nextOrderId();
        orderList.consumeNextOrderId();

        if (isBuy) {
            events.raiseBuyOrderCreated(order.account, order.quantity, order.pricePerCoin, order.orderId, coinBalance, dollarBalance);
        } else {
            events.raiseSellOrderCreated(order.account, order.quantity, order.pricePerCoin, order.orderId, coinBalance, dollarBalance);
        }

        var hasGas = matchOrder(order, orderList, matchOrderList, isBuy);

        // cancel remainder of the order if partially matched with potential matches not finished, or save the order
        if (hasGas && order.quantity > 0) {
            hasGas = saveOrder(order, orderList, isBuy);
        }

        if (!hasGas) {
            dollarBalance = traders.dollarBalance(order.account);
            coinBalance = traders.coinBalance(order.account);

            if (isBuy) {
                dollarBalance += order.quantity * order.pricePerCoin;
                tradersProxy.setDollarBalance(order.account, dollarBalance);
            } else {
                coinBalance += order.quantity;
                tradersProxy.setCoinBalance(order.account, coinBalance);
            }

            if (isBuy) {
                events.raiseBuyOrderCancelled(order.account, order.quantity, order.pricePerCoin, order.orderId,
                        order.originalQuantity, coinBalance, dollarBalance);
            } else {
                events.raiseSellOrderCancelled(order.account, order.quantity, order.pricePerCoin, order.orderId,
                        order.originalQuantity, coinBalance, dollarBalance);
            }
        }
    }

    // returns FALSE if ran out of gas
    // returns TRUE otherwise
    function matchOrder(Order memory order, GxOrderList orderList, GxOrderList matchOrderList, bool isBuy) private returns (bool) {
        uint80 _nextOrderByPrice = matchOrderList.first();
        Order memory matchedOrder;
        uint32 matchedQuantity;
        int64 priceDiff;

        var minGas = constants.MIN_GAS_FOR_MATCH_ORDER();

        while (_nextOrderByPrice != 0) {
            if (msg.gas < minGas) {
                return false; // cancel = true, save = false
            }

            if (order.quantity == 0) {
                return true; // cancel = false, save = true
            }

            matchedOrder = getOrder(matchOrderList, _nextOrderByPrice);

            priceDiff = int64(matchedOrder.pricePerCoin) - int64(order.pricePerCoin);

            if ((isBuy && priceDiff > 0) || (!isBuy && priceDiff < 0)) {
                return true; // cancel = false, save = true
            }

            _nextOrderByPrice = matchedOrder.nextByPrice;

            matchedQuantity = order.quantity > matchedOrder.quantity
                ? matchedOrder.quantity
                : order.quantity;

            matchedOrder.quantity -= matchedQuantity;
            order.quantity -= matchedQuantity;

            if (matchedOrder.quantity == 0) {
                matchOrderList.remove(matchedOrder.orderId);
            } else {
                matchOrderList.update(
                    matchedOrder.orderId,
                    matchedOrder.account,
                    matchedOrder.quantity,
                    matchedOrder.originalQuantity,
                    matchedOrder.pricePerCoin,
                    matchedOrder.expirationTime
                );
            }

            raiseOrderMatchEvent(
                matchedQuantity,
                isBuy ? matchedOrder : order,
                isBuy ? order : matchedOrder
            );
        }

        return true;
    }

    // returns FALSE if ran out of gas
    // returns TRUE otherwise
    function saveOrder(Order memory order, GxOrderList orderList, bool isBuy) private returns (bool) {
        order.previousByPrice = 0;
        order.nextByPrice = orderList.first();

        int64 _nextOrderPriceDifference;

        var minGas = constants.MIN_GAS_FOR_SAVE_ORDER();

        while (order.nextByPrice != 0) {
            // _nextOrderPriceDifference will be
            // a *positive* number if the next order is cheaper
            // a *negative* number if the next order is more expensive
            _nextOrderPriceDifference = int64(order.pricePerCoin) - int64(orderList.getPricePerCoin(order.nextByPrice));

            // we stop looping when we find our location
            // which happens differently for buy and sell orders
            // if buy order, stop when next order is *cheaper*,
            // if sell order, stop when next order is *more expensive*
            if ((isBuy && _nextOrderPriceDifference > 0) ||
               (!isBuy && _nextOrderPriceDifference < 0)) {
                break;
            }

            order.previousByPrice = order.nextByPrice;
            
            order.nextByPrice = getOrder(orderList, order.previousByPrice).nextByPrice;

            if (msg.gas < minGas) {
                return false;
            }
        }
        
        orderList.add(
            order.previousByPrice,   // uint80 previousOrderId, 
            order.orderId,           // uint80 orderId, 
            order.account,           // address account, 
            order.quantity,          // uint32 quantity, 
            order.originalQuantity,  // uint32 originalQuantity, 
            order.pricePerCoin,      // uint32 pricePerCoin, 
            order.expirationTime     // uint expirationTime
        );

        return true;
    }

    function raiseOrderMatchEvent(uint32 _matchedQuantity, Order memory _sellOrder, Order memory _buyOrder) private {
        int160 sellerDollarBalance = traders.dollarBalance(_sellOrder.account) + (_matchedQuantity * _sellOrder.pricePerCoin);
        uint32 sellerCoinBalance = traders.coinBalance(_sellOrder.account);
        tradersProxy.setDollarBalance(_sellOrder.account, sellerDollarBalance);
        //tradersProxy.setCoinBalance(_sellOrder.account, sellerCoinBalance);

        int160 buyerDollarBalance = traders.dollarBalance(_buyOrder.account) + (_buyOrder.pricePerCoin - _sellOrder.pricePerCoin) * _matchedQuantity;
        uint32 buyerCoinBalance = traders.coinBalance(_buyOrder.account) + _matchedQuantity;
        tradersProxy.setDollarBalance(_buyOrder.account, buyerDollarBalance);
        tradersProxy.setCoinBalance(_buyOrder.account, buyerCoinBalance);

        events.raiseSellOrderMatched(
            _sellOrder.account, 
            _buyOrder.account, 
            _matchedQuantity, 
            _sellOrder.pricePerCoin, 
            _buyOrder.orderId, 
            _sellOrder.orderId,
            _sellOrder.originalQuantity, 
            _sellOrder.quantity, 
            sellerCoinBalance, 
            sellerDollarBalance);

        events.raiseBuyOrderMatched(
            _sellOrder.account, 
            _buyOrder.account, 
            _matchedQuantity, 
            _sellOrder.pricePerCoin, 
            _buyOrder.orderId, 
            _sellOrder.orderId,
            _buyOrder.originalQuantity, 
            _buyOrder.quantity, 
            _buyOrder.pricePerCoin, 
            buyerCoinBalance, 
            buyerDollarBalance);
    }
}
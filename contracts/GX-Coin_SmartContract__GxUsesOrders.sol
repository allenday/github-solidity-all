pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';

import './GxOrderList.sol';


contract GxUsesOrders is GxCallableByDeploymentAdmin {
    // a singly-linked list with price in descending order so that a higher bid is matched first and removed or quantity reduced
    GxOrderList public buyOrders;

    // a singly-linked list with price in ascending order so that a lower ask is matched first and removed or quantity reduced
    GxOrderList public sellOrders;

    struct Order {
        uint80 orderId;
        address account;
        uint32 quantity;
        uint32 originalQuantity;
        uint32 pricePerCoin;
        uint expirationTime;

        uint80 nextByPrice;
        uint80 previousByPrice;
    }

    function setBuyOrdersContract(address buyOrderListAddress) public callableByDeploymentAdmin {
        buyOrders = GxOrderList(buyOrderListAddress);
    }

    function setSellOrdersContract(address sellOrderListAddress) public callableByDeploymentAdmin {
        sellOrders = GxOrderList(sellOrderListAddress);
    }

    modifier canUpdateSellOrders {
        if (sellOrders.isOwner(this) && sellOrders.isEditable()) {
            _;
        }
    }

    modifier canUpdateBuyOrders {
        if (buyOrders.isOwner(this) && sellOrders.isEditable()) {
            _;
        }
    }

    function getOrder(GxOrderList orderList, uint80 orderId) internal returns (Order) {
        var (
            _orderId, 
            _next, 
            _previous,
            _account, 
            _quantity, 
            _originalQuantity, 
            _pricePerCoin, 
            _expirationTime
        ) = orderList.get(orderId);

        return Order({
            orderId: _orderId,
            account: _account,
            quantity: _quantity,
            originalQuantity: _originalQuantity,
            pricePerCoin: _pricePerCoin,
            expirationTime: _expirationTime,
            nextByPrice: _next,
            previousByPrice: _previous
        });
    }
}
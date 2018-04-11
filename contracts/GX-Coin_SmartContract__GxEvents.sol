pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';
import './GxOwnedIterable.sol';
import './GxVersioned.sol';
import './GxEventsInterface.sol';


contract GxEvents is GxCallableByDeploymentAdmin, GxEventsInterface, GxOwnedIterable, GxVersioned {
    event TraderRegistered(address to);
    event TraderUnregistered(address to);

    event CoinsSeeded(address to, uint32 amountCoins, uint balanceCoins, uint pricePerCoin);
    event CoinsDeducted(address to, uint32 amountCoins, uint balanceCoins);
    event CoinsAdded(address to, uint32 amountCoins, uint balanceCoins);

    event DollarsFunded(address to, uint160 amountDollars, int160 balanceDollars);
    event DollarsWithdrew(address to, uint160 amountDollars, int160 balanceDollars);
    event DollarsDeducted(address to, uint160 amountDollars, int160 balanceDollars);
    event DollarsAdded(address to, uint160 amountDollars, int160 balanceDollars);

    event DollarsWithdrawalCancelled(address to, uint160 amountDollars, int160 balanceDollars);

    // Order events
    event SellOrderCreated(address to, uint32 amountCoins, uint32 pricePerCoin, uint80 sellOrderId, uint balanceCoins, int160 balanceDollars);
    event SellOrderCancelled(address to, uint amountCoins, uint pricePerCoin, uint sellOrderId, uint originalAmountCoins, uint balanceCoins, int160 balanceDollars);
    event SellOrderMatched(address to, address from, uint amountCoins, uint pricePerCoin, uint buyOrderId, uint sellOrderId,
                    uint originalAmountCoins, uint unmatchedAmountCoins, uint balanceCoins, int160 balanceDollars);

    event BuyOrderCreated(address to, uint amountCoins, uint pricePerCoin, uint buyOrderId, uint balanceCoins, int160 balanceDollars);
    event BuyOrderCancelled(address to, uint amountCoins, uint pricePerCoin, uint buyOrderId, uint originalAmountCoins, uint balanceCoins, int160 balanceDollars);
    event BuyOrderMatched(address to, address from, uint amountCoins, uint pricePerCoin, uint buyOrderId, uint sellOrderId,
                    uint originalAmountCoins, uint unmatchedAmountCoins, uint originalPricePerCoin, uint balanceCoins, int160 balanceDollars);

    function GxEvents(address deploymentAdminsAddress) 
        GxCallableByDeploymentAdmin(deploymentAdminsAddress) 
    {

    }

    function raiseTraderRegistered(address traderAccount) callableByOwner {
        TraderRegistered(traderAccount);
    }

    function raiseTraderUnregistered(address traderAccount) callableByOwner {
        TraderUnregistered(traderAccount);
    }

    function raiseCoinsSeeded(address to, uint32 amountCoins, uint balanceCoins, uint pricePerCoin) callableByOwner {
        CoinsSeeded(to, amountCoins, balanceCoins, pricePerCoin);
    }

    function raiseCoinsDeducted(address to, uint32 amountCoins, uint balanceCoins) callableByOwner {
        CoinsDeducted(to, amountCoins, balanceCoins);
    }

    function raiseCoinsAdded(address to, uint32 amountCoins, uint balanceCoins) callableByOwner {
        CoinsAdded(to, amountCoins, balanceCoins);
    }

    function raiseDollarsFunded(address to, uint160 amountDollars, int160 balanceDollars) callableByOwner {
        DollarsFunded(to, amountDollars, balanceDollars);
    }

    function raiseDollarsWithdrew(address to, uint160 amountDollars, int160 balanceDollars) callableByOwner {
        DollarsWithdrew(to, amountDollars, balanceDollars);
    }

    function raiseDollarsDeducted(address to, uint160 amountDollars, int160 balanceDollars) callableByOwner {
        DollarsDeducted(to, amountDollars, balanceDollars);
    }

    function raiseDollarsAdded(address to, uint160 amountDollars, int160 balanceDollars) callableByOwner {
        DollarsAdded(to, amountDollars, balanceDollars);
    }

    function raiseDollarsWithdrawalCancelled(address to, uint160 amountDollars, int160 balanceDollars) callableByOwner {
        DollarsWithdrawalCancelled(to, amountDollars, balanceDollars);
    }

    function raiseBuyOrderCreated(
        address account, 
        uint32 amount, 
        uint32 pricePerCoin, 
        uint80 buyOrderId, 
        uint balanceCoins, 
        int160 balanceDollars
    )
        public
        callableByOwner
    {
        BuyOrderCreated(account, amount, pricePerCoin, buyOrderId, balanceCoins, balanceDollars);
    }

    function raiseBuyOrderMatched(
        address seller, 
        address buyer, 
        uint matchedAmount, 
        uint pricePerCoin, 
        uint buyOrderId, 
        uint sellOrderId,
        uint originalAmount, 
        uint unmatchedAmount, 
        uint originalPricePerCoin, 
        uint balanceCoins, 
        int160 balanceDollars
    )
        public
        callableByOwner
    {
        BuyOrderMatched(buyer, seller, matchedAmount, pricePerCoin, buyOrderId, sellOrderId, originalAmount, unmatchedAmount, originalPricePerCoin, balanceCoins, balanceDollars);
    }

    function raiseBuyOrderCancelled(
        address account, 
        uint amount, 
        uint pricePerCoin, 
        uint buyOrderId,
        uint originalAmount, 
        uint balanceCoins, 
        int160 balanceDollars
    ) 
        public
        callableByOwner
    {
        BuyOrderCancelled(account, amount, pricePerCoin, buyOrderId, originalAmount, balanceCoins, balanceDollars);
    }

    function raiseSellOrderCreated(
        address account, 
        uint32 amount, 
        uint32 pricePerCoin, 
        uint80 selLOrderId, 
        uint balanceCoins, 
        int160 balanceDollars
    ) 
        public
        callableByOwner
    {
        SellOrderCreated(account, amount, pricePerCoin, selLOrderId, balanceCoins, balanceDollars);
    }

    function raiseSellOrderMatched(
        address seller, 
        address buyer, 
        uint matchedAmount, 
        uint pricePerCoin, 
        uint buyOrderId, 
        uint sellOrderId, 
        uint originalAmount, 
        uint unmatchedAmount, 
        uint balanceCoins, 
        int160 balanceDollars
    ) 
        public
        callableByOwner
    {
        SellOrderMatched(seller, buyer, matchedAmount, pricePerCoin, buyOrderId, sellOrderId, originalAmount, unmatchedAmount, balanceCoins, balanceDollars);
    }

    function raiseSellOrderCancelled(
        address account, 
        uint amount, 
        uint pricePerCoin, 
        uint sellOrderId, 
        uint originalAmount, 
        uint balanceCoins, 
        int160 balanceDollars
    )
        public
        callableByOwner
    {
        SellOrderCancelled(account, amount, pricePerCoin, sellOrderId, originalAmount, balanceCoins, balanceDollars);
    }
}
pragma solidity ^0.4.2;

contract GxEventsInterface {
    function raiseTraderRegistered(address traderAccount);
    function raiseTraderUnregistered(address traderAccount);

    function raiseCoinsSeeded(address to, uint32 amountCoins, uint balanceCoins, uint pricePerCoin);
    function raiseCoinsDeducted(address to, uint32 amountCoins, uint balanceCoins);
    function raiseCoinsAdded(address to, uint32 amountCoins, uint balanceCoins);

    function raiseDollarsFunded(address to, uint160 amountDollars, int160 balanceDollars);
    function raiseDollarsWithdrew(address to, uint160 amountDollars, int160 balanceDollars);
    function raiseDollarsDeducted(address to, uint160 amountDollars, int160 balanceDollars);
    function raiseDollarsAdded(address to, uint160 amountDollars, int160 balanceDollars);

    function raiseDollarsWithdrawalCancelled(address to, uint160 amountDollars, int160 balanceDollars);

    function raiseBuyOrderCreated(
        address account, 
        uint32 amount, 
        uint32 pricePerCoin, 
        uint80 buyOrderId, 
        uint balanceCoins, 
        int160 balanceDollars
    );

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
    );

    function raiseBuyOrderCancelled(
        address account, 
        uint amount, 
        uint pricePerCoin, 
        uint buyOrderId,
        uint originalAmount, 
        uint balanceCoins, 
        int160 balanceDollars
    );

    function raiseSellOrderCreated(
        address account, 
        uint32 amount, 
        uint32 pricePerCoin, 
        uint80 selLOrderId, 
        uint balanceCoins, 
        int160 balanceDollars
    );

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
    );

    function raiseSellOrderCancelled(
        address account, 
        uint amount, 
        uint pricePerCoin, 
        uint sellOrderId, 
        uint originalAmount, 
        uint balanceCoins, 
        int160 balanceDollars
    );
}
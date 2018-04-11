pragma solidity ^0.4.2;

import './GxEditable.sol';
import './GxCallableByDeploymentAdmin.sol';
import './GxRaisesEvents.sol';
import './GxCallableByTrader.sol';
import './GxCallableByAdmin.sol';
import './GxUsesTradersProxy.sol';
import './GxUsesCoinTotals.sol';

//Externally available functions which are affected by a modifier (ie, callableByVerifiedTrader or callableByAdmin)
//  should not explicitly execute a return, and should instead allow execution to reach the end of the function call
//  so that additional modifier code is executed.
contract GxCoin is
    GxCallableByDeploymentAdmin,
    GxEditable, 
    GxRaisesEvents, 
    GxCallableByTrader, 
    GxCallableByAdmin,
    GxUsesTradersProxy,
    GxUsesCoinTotals {

    bool public isTradingOpen = false;

    function GxCoin(address gxDeploymentAdminsAddress) GxCallableByDeploymentAdmin(gxDeploymentAdminsAddress) {
        isEditable = true;

        // this is a short-circuit for `GxCallableByTrader` base contract
        gxCoin = GxCoinInterface(this);
    }

    function setTradingOpen(bool isOpen) callableWhenEditable callableByAdmin {
        isTradingOpen = isOpen;
    }

    function withdraw(uint80 amount) callableWhenEditable callableByTrader {
        int160 balance = traders.dollarBalance(msg.sender) - int160(amount);
        if (balance >= 0) {
            tradersProxy.setDollarBalance(msg.sender, balance);
            events.raiseDollarsWithdrew(msg.sender, amount, balance);
        }
    }
}

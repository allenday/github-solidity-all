pragma solidity ^0.4.2;

import './GxEditable.sol';
import './GxCallableByDeploymentAdmin.sol';
import './GxCallableByAdmin.sol';
import './GxRaisesEvents.sol';
import './GxUsesCoinTotals.sol';
import './GxUsesConstants.sol';
import './GxUsesTradersProxy.sol';
import './GxUsesWallet.sol';

contract GxAdminOperations is
        GxCallableByDeploymentAdmin,
        GxEditable,
        GxRaisesEvents,
        GxUsesCoinTotals,
        GxUsesConstants,
        GxUsesTraders,
        GxUsesTradersProxy,
        GxUsesWallet,
        GxCallableByAdmin {

    function GxAdminOperations(address deploymentAdminsAddress) GxCallableByDeploymentAdmin(deploymentAdminsAddress) {
        isEditable = true;
    }

    modifier isTraderRegistered(address trader) {
        if (trader != 0 && traders.contains(trader)) {
            _;
        }
    }

    //Create coins for an existing account.
    //pricePerCoin - Price Per Coin in cents
    function seedCoins(address receiver, uint32 amount, string notes, uint pricePerCoin) callableWhenEditable callableByAdmin isTraderRegistered(receiver) {  
        if (coinTotals.adjustTotalCoins(int32(amount))) {
            uint32 balance = traders.coinBalance(receiver) + amount;

            tradersProxy.setCoinBalance(receiver, balance);
            events.raiseCoinsSeeded(receiver, amount, balance, pricePerCoin);
        }
    }

    // Register a new account for trading and send some ether to the account
    function registerTraderAccount(address traderAccount) callableWhenEditable callableByAdmin {
        if (!traders.contains(traderAccount)) {
            tradersProxy.add(traderAccount);

            // send enough Ether to the trader for them to start trading
            if (!wallet.pay(traderAccount, constants.INITIAL_TRADER_ETHEREUM())) {
                //throw;
            }

            events.raiseTraderRegistered(traderAccount);
        }
    }

    // Unregister a trader account
    function unregisterTraderAccount(address traderAccount) callableWhenEditable callableByAdmin isTraderRegistered(traderAccount) {
        tradersProxy.remove(traderAccount);
        events.raiseTraderUnregistered(traderAccount);
    }

    function fund(address receiver, uint160 amount) callableWhenEditable callableByAdmin isTraderRegistered(receiver) {
        int160 balance = traders.dollarBalance(receiver) + int160(amount);
        if (balance > 0) {
            tradersProxy.setDollarBalance(receiver, balance);
            events.raiseDollarsFunded(receiver, amount, balance);
        }
    }

    function adjustCoins(address receiver, int32 amount, string notes) callableWhenEditable callableByAdmin isTraderRegistered(receiver) {
        int32 balance = int32(traders.coinBalance(receiver)) + amount;
        if (balance >= 0) {
            if (coinTotals.adjustTotalCoins(amount)) {
                tradersProxy.setCoinBalance(receiver, uint32(balance));
                if (amount < 0) {
                    events.raiseCoinsDeducted(receiver, uint32(-amount), uint32(balance));
                } else {
                    events.raiseCoinsAdded(receiver, uint32(amount), uint32(balance));
                }
            }
        }
    }

    function adjustCash(address receiver, int160 amount, string notes) callableWhenEditable callableByAdmin isTraderRegistered(receiver) {
        int160 balance = traders.dollarBalance(receiver) + amount;
        if (balance >= 0) {
            tradersProxy.setDollarBalance(receiver, balance);
            if (amount < 0) {
                events.raiseDollarsDeducted(receiver, uint160(-amount), balance);
            } else {
                events.raiseDollarsAdded(receiver, uint160(amount), balance);
            }
        }
    }

    function adminCancelWithdrawal(address receiver, uint160 amount, string notes) callableWhenEditable callableByAdmin isTraderRegistered(receiver) {
        int160 balance = traders.dollarBalance(receiver) + int160(amount);
        if (balance >= 0) {
            tradersProxy.setDollarBalance(receiver, balance);
            events.raiseDollarsWithdrawalCancelled(receiver, amount, balance);
        }
    }

    function transferTraderBalance(address oldAccount, address newAccount) callableByAdmin callableWhenEditable isTraderRegistered(oldAccount) {
        if (newAccount != 0) {
            registerTraderAccount(newAccount);

            int32 coinBalance = int32(traders.coinBalance(oldAccount));
            int160 dollarBalance = traders.dollarBalance(oldAccount);

            adjustCoins(oldAccount, -coinBalance, 'transfer');
            adjustCoins(newAccount, coinBalance, 'transfer');

            adjustCash(oldAccount, -dollarBalance, 'transfer');
            adjustCash(newAccount, dollarBalance, 'transfer');

            unregisterTraderAccount(oldAccount);
        }
    }
}

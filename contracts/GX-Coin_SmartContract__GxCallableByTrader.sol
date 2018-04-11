pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';
import './GxUsesConstants.sol';
import './GxUsesTraders.sol';
import './GxUsesWallet.sol';

import './GxCoinInterface.sol';


contract GxCallableByTrader is GxCallableByDeploymentAdmin, GxUsesConstants, GxUsesTraders, GxUsesWallet {
    GxCoinInterface public gxCoin;

    function setGxCoinContract(address gxCoinAddress) public callableByDeploymentAdmin {
        gxCoin = GxCoinInterface(gxCoinAddress);
    }

    modifier callableByTrader {
        uint initialGas = msg.gas;
        if (traders.contains(msg.sender)) {
            if (gxCoin.isTradingOpen()) {
                _;
            }

            uint refund = tx.gasprice * (initialGas - msg.gas + constants.REFUND_EXTRA_GAS());

            if (!wallet.pay(msg.sender, refund)) {
                // TODO: should this throw?
                //throw;
            }
        } else {
            throw;
        }
    }
}
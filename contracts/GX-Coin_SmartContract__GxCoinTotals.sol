pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';
import './GxEditable.sol';
import './GxOwnedIterable.sol';
import './GxVersioned.sol';

contract GxCoinTotals is GxCallableByDeploymentAdmin, GxOwnedIterable, GxVersioned, GxEditable {
    uint32 public constant maxCoinLimit = 75000000;
    uint32 public coinLimit;
    uint32 public totalCoins;

    function GxCoinTotals(address gxDeploymentAdminsAddress) GxCallableByDeploymentAdmin(gxDeploymentAdminsAddress) {
        coinLimit = maxCoinLimit;
    }

    function setCoinLimit(uint32 limit) callableWhenEditable callableByDeploymentAdmin {
        if (limit > 0 && limit <= maxCoinLimit ) {
            coinLimit = limit;
        }
    }

    // convenience method
    function adjustTotalCoins(int32 coins) callableByOwner returns (bool) {
        if (coinLimit == 0) {
            return false;
        }

        if (coins < 0) {
            // so we want to adjust the value of totalCoins by the coins
            // in other words
            //     totalCoins += coins
            // However, that will not compile because totalCoins is a unit32 and amount is an int32
            // So we need to jump through some hoops
            //
            // We can rewrite
            //     totalCoins += coins
            // as
            //     totalCoins = totalCoins + coins
            // or
            //     totalCoins = totalCoins - (-coins)
            // or
            //     totalCoins -= (-coins)
            //
            // rewriting the code like this, and being inside if (coins < 0)
            // allows us to use the cast to uint32 and to get rid of the compilation error

            if (totalCoins < uint32(-coins)) {
                return false;
            }

            totalCoins -= uint32(-coins);
        } else {
            if ((totalCoins + uint32(coins)) > coinLimit) {
                return false;
            }

            totalCoins += uint32(coins);
        }

        return true;
    }

    function setTotalCoins(uint32 coins) callableByDeploymentAdmin {
        totalCoins = coins;
    }

}

pragma solidity ^0.4.15;

import "./CoinCrowdICO.sol";

contract Ambassador {
    CoinCrowdICO icoContract;

    function Ambassador() {
        icoContract = CoinCrowdICO(msg.sender);
    }

    function () payable {
        icoContract.buy.value(msg.value)(msg.sender, this);
    }
}

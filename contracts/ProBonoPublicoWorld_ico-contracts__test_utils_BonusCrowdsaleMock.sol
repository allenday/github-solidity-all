pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "../../contracts/BonusCrowdsale.sol";


contract BonusCrowdsaleMock is Crowdsale, BonusCrowdsale {
    function BonusCrowdsaleMock()
        public
        Crowdsale(now, now + 30, 51, msg.sender)
        BonusCrowdsale(101, now + 5) { }
}

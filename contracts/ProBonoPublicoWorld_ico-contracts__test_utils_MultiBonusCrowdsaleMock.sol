pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "../../contracts/MultiBonusCrowdsale.sol";


contract MultiBonusCrowdsaleMock is Crowdsale, MultiBonusCrowdsale {
    function MultiBonusCrowdsaleMock()
        public
        Crowdsale(now, now + 5 weeks, 510000, msg.sender)
        MultiBonusCrowdsale() { }
}

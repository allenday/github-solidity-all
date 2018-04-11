pragma solidity ^0.4.6;
import './RFQ.sol';

contract RFQRegistry {
    RFQ[] public openRFQs;

    function register(RFQ rfq) {
        openRFQs.push(rfq);
    }
    
    function amountOfOpenRFQs() constant returns (uint) {
        return openRFQs.length;
    }
}

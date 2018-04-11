pragma solidity ^0.4.6;
import './RFQ.sol';
import './Quotation.sol';

contract MatchingEngine {
    Quotation[] quotations;

    function MatchingEngine() {
        addQuotation(new Quotation(100, 'in 3 weeks'));
        addQuotation(new Quotation(95, 'in 2 weeks'));
        addQuotation(new Quotation(25, 'in 2 hours'));
    }

    function getAmountOfQuotations(RFQ rfq) constant returns (uint) {
        return quotations.length;
    }

    function getQuotation(RFQ rfq, uint index) constant returns (Quotation) {
        return quotations[index];
    }

    function amountOfQuotations() constant returns (uint) {
        return quotations.length;
    }

    function addQuotation(Quotation quotation) {
        quotations.push(quotation);
    }
}

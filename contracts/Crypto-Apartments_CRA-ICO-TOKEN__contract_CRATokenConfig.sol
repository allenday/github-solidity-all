pragma solidity ^0.4.15;

contract CRATokenConfig {

    // ------------------------------------------------------------------------
    // Token symbol(), name() and decimals()
    // ------------------------------------------------------------------------
    string public constant SYMBOL = "CRA";
    string public constant NAME = "Crypto-Apartments Token";
    uint8 public constant DECIMALS = 18;
    uint public constant DECIMALSFACTOR = 10**uint(DECIMALS);
    
    uint public constant TOKENS_SOFT_CAP = 13000000 * DECIMALSFACTOR;
    uint public constant TOKENS_HARD_CAP = 30000000 * DECIMALSFACTOR;
    uint public constant TOKENS_TOTAL = 1000000000 * DECIMALSFACTOR;

    // ------------------------------------------------------------------------
    // Tranche 1 crowdsale start date and end date
    // Do not use the `now` function here
    // Start - Thursday, 30-SEP-17 00:00:00 UTC / 1pm GMT 22 June 2017
    // End - Saturday, 30-OKT-17 00:00:00 UTC / 1pm GMT 22 July 2017 
    // ------------------------------------------------------------------------
    uint public constant START_DATE = 1506729600;
    uint public constant END_DATE = 1509321600;
     

    uint public constant LOCKED_1Y_DATE = START_DATE + 365 days;
    uint public constant LOCKED_2Y_DATE = START_DATE + 2 * 365 days;
    uint public CONTRIBUTIONS_MIN = 0 ether;
    uint public CONTRIBUTIONS_MAX = 0 ether;
}
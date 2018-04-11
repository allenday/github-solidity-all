pragma solidity ^0.4.0;

/*
This is a demo contract that shows how to issue 100% of tokens/shares to the investors,
pending an achieved target by the founders, which will increase their ownership of the
tokens/shares up to a defines percentage, defined below as @TargetFoundersTokenPercent
*/
contract Teepee {
    address owner;

    /*
    We use this multiplication constant factor much in the same way the
    1 ether represents 1,000,000,000,000,000,000 wei. We need to use a big
    constant because Solidity doesn't have floating point operations
    */
    uint public constant M = 1 ether;

    /* 
    This is the number of tokens/shares that will be sold to investors. Initially they 
    represent 100% ownership of the company
    */
    uint constant InvestorsTokensCount      = 1000000 * M;

    
    // Value in USD the tokens/shares are initially sold to investor for    
    uint constant InitialMarketCap          = 5000000 * M;

    /*
    Value of the company Market Cap where founders get their @TargetFoundersTokenPercent
    percent of the company in tokens/shares.
    */
    uint constant TargetMarketCap           = 80000000 * M;
    uint constant TargetFoundersTokenPercent= 50 * M;
    
    /*
    We consider this as the amount of work/growth the founders need to
    produce in order to receive their @TargetFoundersTokenPercent percent
    of the company
    */
    uint constant TargetDiffMarketCap       = TargetMarketCap - InitialMarketCap;
    
    // The percentage of the company currently owned by the founders
    uint public FoundersTokensPercent;

    // The percentage of the company currently owned by the investors
    uint public InvestorsTokenPercent;

    // The total number of tokens that are currently in circulation
    uint public LastTokensCount;

    // Number of tokens that are currently awarded to founders
    uint public FoundersTokensCount;

    // The curreny market cap as set by the @update function
    uint public LastMarketCap = InitialMarketCap;

    /*
    Modifier that restricts access to the guarder function to only 
    the owner of this contract.
    */
    modifier onlyByOwner {
        if (msg.sender != owner)
            throw;
        _;
    }

    /*
    @update is used to notify the contract that there is an update to the
    market capitalisation of the company. The function will adjust the 
    founders share ownership according to their percentage of target growth.
    In a production setup, this function will be called by an oracle
    */
    function update(uint256 marketCap) onlyByOwner returns (bool success) {
        if (marketCap < LastMarketCap || marketCap > TargetMarketCap) {
            return false;
        }

        /*
        @ratioOfTarget represents the ratio of company market cap growth that
        the owners currently achieved
        */
        uint ratioOfTarget      = M * (marketCap - InitialMarketCap) / TargetDiffMarketCap;

        /*
        Here we map the @ratioOfTarget to @TargetFoundersTokenPercent to get the 
        percentage of company ownership to be awarded to the founders
        */
        FoundersTokensPercent   = ratioOfTarget * TargetFoundersTokenPercent / M;

        // Recalculate the percentage of company ownership the investors now hold
        InvestorsTokenPercent   = M * 100 - FoundersTokensPercent;

        // Recalculate the total number of tokens in circulation after current dilution
        LastTokensCount         = M * InvestorsTokensCount * 100 / InvestorsTokenPercent;

        /*
        Award the founders with the proportionate number of shares according to their
        current company share ownership
        */
        FoundersTokensCount     = LastTokensCount - InvestorsTokensCount;
        LastMarketCap           = marketCap;

        return true;
    }

    function Teepee() {
        owner = msg.sender;
        update(InitialMarketCap);
    }
}
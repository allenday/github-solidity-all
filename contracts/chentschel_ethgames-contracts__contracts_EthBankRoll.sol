pragma solidity ^0.4.18;

import './StateChannel.sol';

/**
 * @title EthBankRoll
 * @dev Contract that creates a bankroll where funds can be invested, 
 * and winnings shared among investors. 
 */
contract EthBankRoll is StateChannel {

    event onBankRollInvest(address origin, uint amount);
    event onBankRollDivest(address origin, uint amount);

    uint16 public investmentFee;
    uint16 public divestmentFee;

    uint public divestmentFeeUpdate = now;
    
    uint totalShares;
    uint bankrollBalance;

    mapping (address => uint) shareHolders;

    uint32 constant SHARES_PRECISION = 1e8;

    /**
     * @dev Constructor
     * @param investmentFeePerc Fee charged by owner to investors from 0 to 1e4 (100.00%). 
     */
    function EthBankRoll(uint16 investmentFeePerc) public {
        changeInvestmentFee(investmentFeePerc);
    }

    /**
     * @dev Changes investment fee
     * @param amount number between 0 and 10000 -> (100.00%). 
     */
    function changeInvestmentFee(uint16 amount) onlyOwner public {
        require(amount <= 10000);
        investmentFee = amount;
    }

    /**
     * @dev Changes divestment fee
     * @param amount number between 0 and 2500 -> (25.00%). 
     */
    function changeDivestmentFee(uint16 amount) onlyOwner public {
        require(amount <= 2500);

        /*
         * Rules are: no more than 1% increment every 30 days.
         * This will add previsibility to bankroll investors.
         */
        require(divestmentFeeUpdate + 30 days < now);

        if (amount > divestmentFee) {
            require(amount - divestmentFee <= 100);
            
            divestmentFeeUpdate = now;
        }
        divestmentFee = amount;
    }
    

    function bankRollInvest() public payable {
        require(msg.value > 0);
        
        // Get available amount after owner fee 
        uint valueAfterFee = msg.value * ((10000 - investmentFee) / 10000);

        // Send investment fee to contract owner
        if (investmentFee > 0) {
            pendingWithdrawals[owner] += msg.value - valueAfterFee;
        }

        /**
         * Get amount of shares for this investment.
         * We need to substract valueAfterFee from current contract balance 
         * in shareprice() call to calculate price accurately
         */
        uint shares = valueAfterFee / (getSharePrice() / SHARES_PRECISION);

        shareHolders[msg.sender] += shares;
        totalShares += shares;

        // Update Bankroll balance
        bankrollBalance += valueAfterFee;

        onBankRollInvest(msg.sender, valueAfterFee);
    }

    /**
     * @dev bankRollDivest
     * @param value amount in wei to divest from bankroll
     */
    function bankRollDivest(uint value) public {
        
        require(this.balance > 0);
        
        // Check value allowed
        uint sharePrice = getSharePrice();
        uint maxAmount = shareHolders[msg.sender] * (sharePrice / SHARES_PRECISION);

        require(value > 0 && value <= maxAmount);

        // Get shares amount.
        uint shares = value / (sharePrice / SHARES_PRECISION);

        shareHolders[msg.sender] -= shares;
        totalShares -= shares;

        if (shareHolders[msg.sender] == 0) {
            delete shareHolders[msg.sender];
        }

        // Update Bankroll balance
        bankrollBalance -= value;

        // Send Divestment fee to contract owner
        if (divestmentFee > 0) {
            uint valueAfterFee = value * ((10000 - divestmentFee) / 10000);
            
            pendingWithdrawals[owner] += value - valueAfterFee;
            pendingWithdrawals[msg.sender] += valueAfterFee;

        } else {
            pendingWithdrawals[msg.sender] += value;
        }

        onBankRollDivest(msg.sender, value);
    }

    function getSharesCount() public constant returns (uint) {
        return shareHolders[msg.sender];
    }

    function getInvestmentValue() public constant returns (uint) {
        return shareHolders[msg.sender] * (getSharePrice() / SHARES_PRECISION);
    }

    /**
     * @dev getSharePrice get current share price. 
     */
    function getSharePrice() private constant returns (uint) {
        if (totalShares > 0) {
            return (bankrollBalance / totalShares) * SHARES_PRECISION;
        }
        return SHARES_PRECISION;
    }

}

/** 
 * @notice Smartex Funds Manager
 * @author Christopher Moore cmoore@smartex.io - Smartex.io Ltd. 2016-2017 - https://smartex.io
 */

contract SmartexFundsManager is owned {

    mapping(uint => Fund) funds;

    /** 
     * @notice Fund  
     */
    struct Fund {
        mapping(uint => Shareholder) shareholders;
        uint balance;
        uint totalShares;
        uint totalShareholders;
        uint sharesLeft;
    }

    /** 
     * @notice Shareholder 
     */
    struct Shareholder {
        address payoutAccount;
        uint shares;
    }


    /** 
     * @notice Incoming transaction Event
     */
    event IncomingTx(
        uint indexed blockNumber,
        address sender,
        uint value,
        uint timestamp
    );

    /** 
     * @notice Outgoing transaction Event
     */
    event OutgoingTx(
        uint indexed blockNumber,
        address recipient,
        uint value,
        uint timestamp
    );


    /** 
     * @notice Dividend error event
     */
    event DividendError(
        uint id,
        uint startOffset,
        uint stopOffset,
        uint balance,
        uint dividend,
        uint timestamp
    );
    
    /** 
     * @notice Settlement error event
     */
    event NewShareholder(
        uint id,
        address account,
        uint shares,
        uint timestamp
    );

    /**
     * @notice Contract constructor
     */
    function SmartexFundsManager() {
        funds[0] = Fund(0, 1000000, 0, 1000000);
    }

    /**
     * @notice Add a shareholder
     * @param payoutAccount  (Shareholder payout address)
     * @param shares  (Shareholder number of shares)
    */
    function addShareholder(address payoutAccount, uint shares) onlyOwner  {
        Fund f = funds[0];
        if (shares <= f.sharesLeft) {
            f.shareholders[f.totalShareholders] = Shareholder({
                payoutAccount: payoutAccount,
                shares: shares
            });
            f.sharesLeft -= shares;
            ++f.totalShareholders;
            NewShareholder(f.totalShareholders, payoutAccount, shares, now);
        } else {
            //no more shares left
            throw;
        }
    }

    /**
     * @notice Pay dividends to shareholders
     * @param startOffset ()
     * @param stopOffset ()
     * @param value (value in wei)
     */
    function payDividends(uint startOffset, uint stopOffset, uint value) onlyOwner {
        Fund f = funds[0];
        for (uint i = startOffset; i < stopOffset; i++) {
            Shareholder s = f.shareholders[i];
            uint dividend = (value * s.shares);
            if (this.balance >= dividend) {
                if (s.payoutAccount.send(dividend)) {
                    OutgoingTx(block.number, s.payoutAccount, dividend, now);
                } else {
                    DividendError(i, startOffset, stopOffset, this.balance, dividend, now);
                    throw;
                }
            } else {
                //not enough funds left
                DividendError(i, startOffset, stopOffset, this.balance, dividend, now);
            }
        }
    }

    /**
     * @notice Pay dividend to shareholder
     * @param shareholderId ()
     * @param value (value in wei)
     */
    function payDividend(uint shareholderId, uint value) onlyOwner {
        Fund f = funds[0];
        Shareholder s = f.shareholders[shareholderId];
        uint dividend = (value * s.shares);
        if (this.balance >= dividend) {
            if (s.payoutAccount.send(dividend)) {
                OutgoingTx(block.number, s.payoutAccount, dividend, now);
            } else {
                DividendError(shareholderId, 0, 0, this.balance, dividend, now);
                throw;
            }
        } else {
            //not enough funds left
            DividendError(shareholderId, 0, 0, this.balance, dividend, now);
        }
    }

    /**
     * @notice Sweep funds
     * @param _to (Funds recipient)
     */
    function sweep(address _to) payable onlyOwner {
            if (!_to.send(this.balance)) throw; 
    }
    
    /**
     * @notice Advanced send
     * @param _to (transaction Recipient)
     * @param _value (transaction value)
     * @param _data (additional payload)
     */
    function advSend(address _to, uint _value, bytes _data)  onlyOwner {
            _to.call.value(_value)(_data);
    }
    
    /**
     * @notice anonymous function
     * @notice Triggered by invalid function calls and incoming transactions
     */
    function() payable {
        IncomingTx(block.number, msg.sender, msg.value, now);
    }    
}
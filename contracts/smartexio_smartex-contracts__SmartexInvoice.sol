/** 
 * @notice Smartex Invoice
 * @author Christopher Moore cmoore@smartex.io - Smartex.io Ltd. 2016-2017 - https://smartex.io
 */

contract SmartexInvoice is owned {

    address sfm;

    /** 
     * @notice Incoming transaction Event
     * @notice Logs : block number, sender, value, timestamp
     */
    event IncomingTx(
        uint indexed blockNumber,
        address sender,
        uint value,
        uint timestamp
    );

    /** 
     * @notice Refund Invoice Event
     * @notice Logs : invoice address, timestamp
     */
    event RefundInvoice(
        address invoiceAddress,
        uint timestamp
    );

    /**
     * @notice Invoice constructor
     */
    function SmartexInvoice(address target, address owner) {
        sfm = target;
        transferOwnership(owner);
    }


    /**
     * @notice Refund invoice  
     * @param recipient (address refunded)
     */
    function refund(address recipient) onlyOwner {
        RefundInvoice(address(this), now);
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
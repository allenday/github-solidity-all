/** 
 * @notice Smartex Funds Manager
 * @author Christopher Moore cmoore@smartex.io - Smartex.io Ltd. 2016 - https://smartex.io
 */

contract SmartexController is owned {

    mapping(uint => Invoice) invoices;
    uint totalInvoices;

    /** 
     * @notice Invoice  
     */
    struct Invoice {
        address creator;
        address InvoiceAddress;
        uint blockCreatedOn;
    }
    

    /** 
     * @notice Create invoice event
     */
    event CreateInvoice(
        uint blockNumber,
        uint id,
        address fundManager,
        uint timestamp
    );

    function SmartexController() {
        totalInvoices = 0;
    }

    /**
     * @notice Create Invoice
     * @param id  (incremental id)
     * @param fundManager  (fund manager contract address)     
      */
    function createInvoice(uint id, address fundManager, address owner) onlyOwner  {
        address InvoiceAddress = new SmartexInvoice(fundManager, owner);
        invoices[id] = Invoice({
            creator: msg.sender,
            InvoiceAddress: InvoiceAddress,
            blockCreatedOn: block.number
        });
        CreateInvoice(block.number, id, fundManager, now);
        ++totalInvoices;
    }

    /**
     * @notice Refund Invoice
     * @param invoiceAddress  (Invoice address)
     * @param recipient  (Refund recipient)     
      */    
    function refundInvoice(address invoiceAddress, address recipient) onlyOwner {
        SmartexInvoice sI = SmartexInvoice(invoiceAddress);
        sI.refund(recipient);
    }

    /**
     * @notice Get address of invoice
     * @param id  (Invoice id)
       */  
    function getInvoiceAddress(uint id) constant returns(address) {
        Invoice i = invoices[id];
        return i.InvoiceAddress;
    }

    /**
     * @notice Get total invoices number
       */ 
    function getTotalInvoices() constant returns(uint) {
        return totalInvoices;
    }

}
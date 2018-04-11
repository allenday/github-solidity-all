pragma solidity >=0.4.15;

import "zeppelin/ownership/Ownable.sol";
import "./KiwiUtils.sol";
import "./Kiwi.sol";

contract KiwiInvoices is KiwiUtils, Ownable {

  Kiwi kiwi;

  event InvoiceCreated(address indexed to, uint256 amount, string reference);
  event InvoiceCancelled();
  event InvoicePaid(bytes32 id);
  event InvoicePartiallyPaid(bytes32 id, uint256 paid, uint256 owing);
  event Debug(uint256 value);

  enum InvoiceStatus {
    CANCELLED,
    DRAFT,
    ACTIVE,
    PAID
  }

  struct Invoice{
    address to;           //address of payer
    uint256 amount;       //amount to be paid
    string reference;     //arbitary reference
    uint256 paid;         //amount paid
    InvoiceStatus status;
    uint index;           //pointer keeping track of postion in invoiceIndex
  }

  mapping (bytes32 => Invoice) private invoices;   //map all invoices with invoice id
  bytes32[] private invoiceIndex;                  //keep track of our invoices

  modifier checkInvoiceStatus(Invoice storage inv, InvoiceStatus status) {
    require(inv.status == status);
    _;
  }

  function isInvoice(bytes32 _id) public constant returns (bool isIndeed) {

    if(invoiceIndex.length == 0) return false;
    return (invoiceIndex[invoices[_id].index] == _id);
  }

  /*
   * creates a new invoice
   * @var _id unique identifier
   * @var _to a valid ethereum address to associate the invoice with
   * @var _amount is the total amount in ether
   * @var _reference is a internal reference that can be used as desired
   */
  function createInvoice(bytes32 _id, address _to, uint256 _amount, string _reference)
    onlyOwner public returns (uint index) {

      require(isInvoice(_id) == false);

      //insert new invoice
      Invoice storage inv = invoices[_id];
      inv.to = _to;
      inv.amount = _amount;
      inv.reference = _reference;
      inv.paid = 0;
      inv.status = InvoiceStatus.ACTIVE;
      inv.index = invoiceIndex.push(_id) - 1;

      //fire event
      InvoiceCreated(_to, _amount, _reference);

      return invoiceIndex.length - 1;
  }

  function cancelInvoice(bytes32 _id)
    onlyOwner public {

      require(isInvoice(_id) == true);

      //delete invoice (see notes for logic)
      uint rowToDelete = invoices[_id].index;
      bytes32 keyToMove = invoiceIndex[invoiceIndex.length-1];
      invoiceIndex[rowToDelete] = keyToMove;
      invoices[keyToMove].index = rowToDelete;
      invoiceIndex.length--;

      //fire event
      InvoiceCancelled();
  }

  /*
   * Allows paying invoices with either tokens, ether or combination of both
   * @var _id is the invoice id
   * @var _amount is the amount of tokens
   */
  function payInvoice(bytes32 id, uint256 _amount)
    checkInvoiceStatus(invoices[id], InvoiceStatus.ACTIVE)
    payable public {

      require(isInvoice(id) == true);
      require(msg.value > 0 || _amount > 0);

      uint256 ether_received = msg.value;
      uint256 tokens_received = toTuis(_amount);
      uint256 tokens_value = toEth(_amount);
      uint256 _owing = 0;

      //retrieve the invoice
      Invoice inv = invoices[id];
      uint256 tobepaid = inv.amount - inv.paid;

      if(ether_received <= 0) {

          if(tobepaid >= tokens_value) {
              _owing = tobepaid - tokens_value;
              burn(msg.sender, tokens_received);
              inv.paid += tokens_value;
          } else {
            uint256 tokenstoburn = toKiwi(tokens_value - (tokens_value - tobepaid));
            burn(msg.sender, (tokenstoburn));
            inv.paid += tobepaid;
          }

      } else {

        if(tobepaid >= ether_received) {
          _owing = tobepaid - ether_received;
          inv.paid += ether_received;


          if(_owing != 0 && tokens_value != 0) {
            if(_owing >= tokens_value) {
                _owing = _owing - tokens_value;
                burn(msg.sender, tokens_received);
                inv.paid += tokens_value;
            } else {
              tokenstoburn = toKiwi(tokens_value - (tokens_value - _owing));
              burn(msg.sender, (tokenstoburn));
              inv.paid += _owing;
              _owing = 0;
            }
          }


        } else {
          inv.paid += tobepaid;
          _owing = 0;

          //extra ether to be converted to tokens
          uint256 extraether = ether_received - tobepaid;
          mint(msg.sender, toKiwi(extraether));

        }

      }

      //update status and fire event
      if(_owing <= 0) {
          inv.status = InvoiceStatus.PAID;
          InvoicePaid(id);
      } else {
          InvoicePartiallyPaid(id, inv.paid, _owing);
      }

  }

  function getInvoiceCount() public constant returns (uint count) {
    return invoiceIndex.length;
  }

  function getInvoice(bytes32 _id) public constant returns (uint256 amount, uint256 paid, InvoiceStatus status ) {
      require(isInvoice(_id) == true);
      return(
          invoices[_id].amount,
          invoices[_id].paid,
          invoices[_id].status
      );
  }

  function getInvoiceStatus(bytes32 _id) public constant returns (InvoiceStatus status) {
    require(isInvoice(_id) == true);
    return(
        invoices[_id].status
    );
  }

  function getInvoiceAmountPaid(bytes32 _id) public constant returns (uint256 amount) {
    require(isInvoice(_id) == true);
    return(
        invoices[_id].paid
    );
  }

  function getInvoiceBalance(bytes32 _id) public constant returns (uint256 balance) {
    require(isInvoice(_id) == true);
    return(
        invoices[_id].amount - invoices[_id].paid
    );
  }

}

import "./owned.sol";
import "./localsCointoken.sol";
//onlyReputable

contract localsInOut is owned {

  event OfferAdded(uint proposalID, address recipient, uint amount, string description);
  event Confirmed(uint offerNumber,  bool supportsProposal, address confirmator);
  Offer[] public offers;
  uint public numOffers;

  struct Offer {
    address creator;
    address claimer;
    uint amount;
    string descriptionipfs;
    uint validityStart;
    uint validityEnd;
    uint status;
    uint geoMapping;
    uint duration;
    uint numberOfConfirmations;
    /* 0: Created, 1: Live, 2: Claimed, 3: Executed, 4: Validated, 5: Expired */
    Confirmation[] confirmations;
    mapping (address => bool) confirmed;
  }

  struct Confirmation {
      bool inSupport;
      address voter;
  }

  /*modifier onlyReputable {
      if (repCoin.balanceOf(msg.sender) == 0) throw;
      _
  }*/

  /* Function to create a new proposal */
  function newOffer(
    address _claimer,
    uint _amount,
    string _descriptionipfs,
    uint _validityStart,
    uint _duration
  )
      //onlyReputable
      returns (uint offerID)
  {
      offerID = offers.length++;
      Offer o = offers[offerID];
      o.creator = msg.sender;
      o.claimer = _claimer;
      o.amount = _amount;
      o.descriptionipfs = _descriptionipfs;
      o.validityStart = _validityStart;
      o.validityEnd = now + _duration * 1 minutes;
      o.status = 0;
      o.numberOfConfirmations = 0;
      OfferAdded(offerID, _claimer, _amount, _descriptionipfs);
      numOffers = offerID+1;
  }

  function claim(uint offerNumber) {
    Offer o = offers[offerID];
    o.claimer = msg.sender;
  }

  /* */
  function confirm(uint offerNumber, bool supportsConfirmation)
      /*onlyReputable*/
      returns (uint confirmID)
  {
      Offer o = offers[offerNumber];
      if (o.confirmed[msg.sender] == true) throw;

      confirmID = o.confirmations.length++;
      o.confirmations[confirmID] = Confirmation({inSupport: supportsConfirmation, voter: msg.sender});
      o.confirmed[msg.sender] = true;
      o.numberOfConfirmations = confirmID +1;
      Confirmed(offerNumber, supportsConfirmation, msg.sender);
  }

  function executeOffer(uint offerNumber, bytes transactionBytecode) returns (int result) {
      Offer o = offers[offerNumber];
      // mint offer amount and send to claimer
  }

  function kill() { if (msg.sender == owner) suicide(owner); }
}

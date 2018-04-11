pragma solidity ^0.4.4;

contract PePaDe {
  event NewShipment(address shipment);
  address public owner;

  function PePaDe() {
    owner = msg.sender;
  }

  function createShipment(address _recipient, string _originAddress,
          string _destAddress, int _maxTemp, int _minTemp,
          uint _weightInKg, uint _expirationTime) public
          returns(address contractAddress) {
    Shipment shipment = new Shipment(msg.sender, _recipient,
           _originAddress, _destAddress, _maxTemp, _minTemp,
           _weightInKg, _expirationTime);
    NewShipment(shipment);
    return shipment;
  }

  function () payable public {}

  function selfDestruct() {
    require(msg.sender == owner);
    selfdestruct(owner);
  }
}

contract Shipment {
  enum State {
    Proposed, WithOffer, Agreed, Funded, Shipping, Delivered, Paid, Expired, Exception
  }

  struct DelivererCandidate {
    address id;
    uint proposedFee;
    uint offerExpiration;
  }

  address public sender;
  address public deliverer;
  address public recipient;
  address public iotNode;
  uint weightInKg;
  string originAddress;
  string destAddress;
  State public state;
  int maxTemp;
  int minTemp;
  uint public fee;
  uint deposit;
  mapping (uint => DelivererCandidate) candidates;
  uint candidateLen;
  uint creationTime;
  uint expirationTime;
  bool senderConfirmed;
  bool delivererConfirmed;

  event NewCandidate(uint index, address deliverCandidate, uint proposedFee, uint offerExpiration);
  event DelivererSelected(address selectedDeliverer, uint finalFee);
  event ContractFunded();
  event ParcelShipped();
  event ParcelDelivered();
  event ParcelExpired();
  event FeePaid();
  event InsufficientFunds(uint deficit);
  event TemperatureException(int temperature);
  event ContractDestroyed();

  modifier onlySender {
    require(msg.sender == sender);
    _;
  }

  modifier onlyRecipient {
    require(msg.sender == recipient);
    _;
  }

  modifier onlyDeliverer {
    require(msg.sender == deliverer);
    _;
  }

  modifier onlyIotNode{
    require(msg.sender == iotNode);
    _;
  }

  modifier shippingState {
    require(state == State.Shipping);
    _;
  }

  modifier deliveredState {
    require(state == State.Delivered);
    _;
  }

  modifier garbageCollectable {
    require(state == State.Paid || state == State.Expired || state == State.Exception
      || ((state == State.Agreed || state == State.Shipping) && now >= creationTime + expirationTime));
    _;
  }

  function Shipment(address _sender, address _recipient, string _originAddress,
           string _destAddress, int _maxTemp, int _minTemp,
           uint _weightInKg, uint _expirationTime) payable {
    sender = _sender;
    recipient = _recipient;
    weightInKg = _weightInKg;
    originAddress = _originAddress;
    destAddress = _destAddress;
    maxTemp = _maxTemp;
    minTemp = _minTemp;
    creationTime = now;
    expirationTime = _expirationTime;
    candidateLen = 0;
    state = State.Proposed;
  }

  // function for the frontend to retrieve data to print on screen
  function getData() constant public returns(address _recipient, uint _weight,
      string _origin, string _dest, int _maxTemp, int _minTemp, uint _cTime,
      uint _eTime) {
    return(recipient, weightInKg, originAddress, destAddress, maxTemp, minTemp, creationTime, expirationTime);
  }

  // fallback function; also check if we have now enough funds to start the contract
  function () payable {
    if (state == State.Agreed && this.balance >= fee) {
      state = State.Funded;
      ContractFunded();
    }
  }

  // utility function to check balance
  function getBalance() constant public returns(uint) {
    return this.balance;
  }

  // should we ask/check for deposit here?
  function deliverCandidate(uint _proposedFee, uint _offerExpiration) public returns(uint) {
    require(state == State.Proposed || state == State.WithOffer);
    uint index = candidateLen;
    candidates[index] = DelivererCandidate({id: msg.sender,
                                            proposedFee: _proposedFee,
                                            offerExpiration: _offerExpiration});
    candidateLen += 1;
    NewCandidate(index, msg.sender, _proposedFee, _offerExpiration);
    if (state == State.Proposed)
      state = State.WithOffer;
    return index;
  }

  function selectDeliverer(uint index) onlySender public {
    require(state == State.WithOffer);
    require(index < candidateLen);
    DelivererCandidate memory selected = candidates[index];
    deliverer = selected.id;
    fee = selected.proposedFee;
    // this could be specified separately by another call to use a different address, right now it is useless
    iotNode = deliverer;
    DelivererSelected(deliverer, fee);
    if (this.balance >= fee) {
      state = State.Funded;
      ContractFunded();
    } else {
      state = State.Agreed;
    }
  }

  function confirmCollection() public {
    require(state == State.Funded);
    if (msg.sender == sender)
      senderConfirmed = true;
    else if (msg.sender == deliverer)
      delivererConfirmed = true;
    if (senderConfirmed && delivererConfirmed) {
      state = State.Shipping;
      ParcelShipped();
    }
  }

  function confirmReception() onlyRecipient shippingState public {
    if (now - creationTime <= expirationTime) {
      state = State.Delivered;
      ParcelDelivered();
    } else {
      state = State.Expired;
      ParcelExpired();
    }
  }

  function withdrawPayment() onlyDeliverer deliveredState public {
    if (msg.sender.send(fee)) {
      state = State.Paid;
      FeePaid();
    } else {
      // this should really never happen, but just in case
      uint deficit = fee - this.balance;
      InsufficientFunds(deficit);
    }
  }

  function notifyTempBreach(int temperature) onlyIotNode public {
    require(temperature > maxTemp || temperature < minTemp);
    state = State.Exception;
    TemperatureException(temperature);
  }

  function garbageCollect() onlySender garbageCollectable public {
    ContractDestroyed();
    selfdestruct(sender);
  }
}

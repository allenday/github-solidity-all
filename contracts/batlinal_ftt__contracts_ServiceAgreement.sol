pragma solidity ^0.4.4;

import "./ServiceToken.sol";
import "./AgreementFactory.sol";
import "./HashLib.sol";

/* Created by factory in order to sign agreement and generate token contract */
contract ServiceAgreement {

  enum States { Created, Proposed, Withdrawn, Accepted, Rejected }

  event StateChange(States indexed oldState, States indexed newState);
  event Token(bytes32 indexed contentHash, ServiceToken indexed token);

  States public state;
  ServiceToken public token; // link to the created token
  AgreementFactory public factory; // can be used to validate that contract is recognised by factory

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  uint public validFrom;
  uint public expiresEnd;
  bytes32 public contentHash;
  address public issuer;
  address public beneficiary;
  uint256 public price;

  modifier onlyIssuer {
    require(msg.sender == issuer);
    _;
  }

  modifier onlyBeneficiary {
    require(msg.sender == beneficiary);
    _;
  }

  modifier onlyProposed {
    require(state == States.Proposed);
    _;
  }

  modifier onlyCreated {
    require(state == States.Created);
    _;
  }

  function ServiceAgreement(
    string _name,
    string _symbol,
    uint8 _decimals,
    uint256 _totalSupply,
    uint _validFrom,
    uint _expiresEnd,
    address _issuer,
    address _beneficiary,
    uint256 _price
    ) {

      name = _name;
      symbol = _symbol;
      decimals = _decimals;
      totalSupply = _totalSupply;
      validFrom = _validFrom;
      expiresEnd = _expiresEnd;
      issuer = _issuer;
      beneficiary = _beneficiary;
      price = _price;

      factory = AgreementFactory(msg.sender);
      state = States.Created;
  }

  /* submitted by the issuer as the first signiture including docId of legal doc */
  function propose(bytes32 hashedHash) onlyIssuer onlyCreated {
    contentHash = hashedHash;
    state = States.Proposed;
    StateChange(States.Created, States.Proposed);
  }

  /* allow issuer to withdraw aggreement proposal before it is accepted */
  function withdraw() onlyIssuer onlyProposed {
    state = States.Withdrawn;
    StateChange(States.Proposed, States.Withdrawn);
  }

  /* beneficiary is able to agree to agreement proposal i.e. sign it, passing docId ass safety check*/
  function accept(bytes32 _contentHash) onlyBeneficiary onlyProposed payable {
    require(HashLib.matches(contentHash, _contentHash)); // matches double hash in agreement to single hash in token
    require(msg.value == totalSupply * price); // checks that enough ether has been sent to pay for contract

    issuer.transfer(totalSupply * price); // transfer the ether balance

    contentHash = _contentHash;
    token = new ServiceToken();
    state = States.Accepted;
    StateChange(States.Proposed, States.Accepted);
    Token(contentHash, token);
  }

  function reject() onlyBeneficiary onlyProposed {
    state = States.Rejected;
    StateChange(States.Proposed, States.Rejected);
  }
}

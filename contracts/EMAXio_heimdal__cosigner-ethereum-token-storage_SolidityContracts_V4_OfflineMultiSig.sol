pragma solidity ^0.4.15;

// Offline Multi-Sig Contract
// Allows a single transaction to be signed by multiple parties before being submitted to the contract

// Due to the potential size of the signature data with multiple signers, it's easier to store the data
// than it is to pass it through function calls. We risk a stack overflow making when making these calls in a
// functional pattern.

import "StorageBase.sol";
import "dappsys/ds-note/note.sol";

contract OfflineMultiSig is StorageBase(0x0000000000000000000000000000000000000000), DSNote {
  // The required number of signers to perform any action
  uint _required;

  uint _numOwners;
  mapping(address => uint) _ownerIndex;
  mapping(uint => address) _owners;

  address _sender;
  uint _senderSigned;
  address _admin;
  uint _adminSigned;
  mapping(address => uint) _senderNonce;

  uint _numTransactions;
  mapping(uint => address) _transactionsTo;
  mapping(uint => uint) _transactionsValue;

  uint _numSignatures;
  mapping(uint => SigData) _signatures;

  bool public contractFrozen;

  struct SigData {
    uint8 sigV;
    bytes32 sigR;
    bytes32 sigS;
  }

  function ownerIndexBit(address addr) constant returns(uint) {
    return _ownerIndex[addr];
  }

  function getNonce(address txSender) constant returns(uint) {
    return _senderNonce[txSender] + 1;
  }

  function isOwner(address addr) constant returns(bool) {
    return (_ownerIndex[addr] > 0);
  }

  function getOwners() constant returns(address[]) {
    address[] memory ownersList = new address[](_numOwners);
    for (uint i = 0; i < _numOwners; i++) {
      ownersList[i] = _owners[i + 1];
    }

    return ownersList;
  }

  function calculateTxHash(address txSender, address[] recipients, uint[] values) constant returns(bytes32) {
    bytes32 hash = 0x00;
    for (uint i = 0; i < recipients.length; i++) {
      hash = sha3(hash, recipients[i], values[i], _senderNonce[txSender] + 1, this);
    }

    return hash;
  }

  function calculateAdminTxHash() constant returns(bytes32) {
    return sha3(_senderNonce[_admin] + 1, this);
  }

  function confirmTransactionSig(bytes32 transactionHash) internal returns(bool) {
    _senderSigned = 0;
    _adminSigned = 0;
    uint signers = 0;
    uint numSigners = 0;
    for (uint i = 0; i < _numSignatures && i < 8; i++) {
      address signer = ecrecover(transactionHash, _signatures[i].sigV, _signatures[i].sigR, _signatures[i].sigS);
      uint ownerBit = ownerIndexBit(signer);
      uint ownerValue = 2 ** ownerBit;
      if (ownerBit > 0 && (signers & ownerValue == 0)) {
        signers |= ownerValue;
        numSigners++;
      }
      if (signer == _sender) {
        _senderSigned = 1;
      }
      if (signer == _admin) {
        _adminSigned = 1;
      }
    }

    assert(numSigners >= _required);
    return true;
  }

  function confirmTransaction() internal returns(bool) {
    address[] memory transactionsToArray = new address[](_numTransactions);
    for(uint i = 0; i < _numTransactions; i++) {
      transactionsToArray[i] = _transactionsTo[i];
    }
    uint[] memory transactionsValueArray = new uint[](_numTransactions);
    for(i = 0; i < _numTransactions; i++) {
      transactionsValueArray[i] = _transactionsValue[i];
    }
    return confirmTransactionSig(calculateTxHash(_sender, transactionsToArray, transactionsValueArray));
  }

  function confirmAdminTx() internal returns(bool) {
    _sender = _admin;
    return (confirmTransactionSig(calculateAdminTxHash()) && _adminSigned == 1);
  }

  function OfflineMultiSig(address tokenContract, address admin, address[] owners, uint required) {
    _tokenContract = tokenContract;
    _admin = admin;
    for (uint i = 0; i < owners.length; i++) {
      _owners[i + 1] = owners[i];
      _ownerIndex[owners[i]] = i + 1;
    }
    _numOwners = owners.length;
    _required = required;
  }

  function internalTransfer() internal returns(bool) {
    return true;
  }

  function offlineTransfer(address sender, address[] to, uint[] value,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) note freezable external {
    _sender = sender;
    _numTransactions = to.length;
    for (uint i = 0; i < _numTransactions; i++) {
      _transactionsTo[i] = to[i];
      _transactionsValue[i] = value[i];
    }

    _numSignatures = sigV.length;
    for (i = 0; i < _numSignatures; i++) {
      _signatures[i].sigV = sigV[i];
      _signatures[i].sigR = sigR[i];
      _signatures[i].sigS = sigS[i];
    }

    if (confirmTransaction() && _senderSigned == 1) {
      internalTransfer();
    }
  }

  function freezeContract(bool freeze, uint8[] sigV, bytes32[] sigR, bytes32[] sigS) note external {
    _numSignatures = sigV.length;
    for (uint i = 0; i < _numSignatures; i++) {
      _signatures[i].sigV = sigV[i];
      _signatures[i].sigR = sigR[i];
      _signatures[i].sigS = sigS[i];
    }
    assert(confirmAdminTx());
    contractFrozen = freeze;
    ContractFrozen(freeze);
  }

  modifier freezable {
    assert(!contractFrozen);
     _;
  }
}

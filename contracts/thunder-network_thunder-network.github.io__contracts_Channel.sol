pragma solidity ^0.4.4;

import "./strings.sol";

contract Channel {
  using strings for *;

  address owner;
  address partner;
  uint256 stake;
  bool matched = false;
  uint256 expirationBlockTime;
  uint256 nonce;
  uint256 ownerBalance;
  uint256 partnerbalance;

  event ChannelClosed(uint256 nonce, uint256 ownerBalance, uint256 partnerBalance);

  modifier onlyOwner () {
    if (msg.sender!=owner) throw;
    _;
  }

  modifier isMatched () {
    if(!matched) throw;
    _;
  }

  enum State {
    created,
    open,
    closed,
    settled
  }

  function Channel (address _owner, address _partner) {
    owner= _owner;
    partner = _partner;

    // 24 hour in blocks, time player 1 has to reveal once matched
    // WIP
    expirationBlockTime = 7200;
  }

  function initialDeposit (address _sender) payable {
    if (msg.value <= 0) throw;
    if (_sender != owner) throw;
    stake = msg.value;
  }

  // no fallback
  function () {}

  function matchStake () payable {
    if (msg.sender != partner) throw;
    if (msg.value != stake) throw;
    if (matched) throw;
    matched = true;
  }

  function validateMessage(string m, bytes32 h, uint8 v, bytes32 r, bytes32 s)
    public constant returns (bool) {
    if(sha3(m) != h) throw;

    var (_nonce, _ownerBalance, _partnerBalance) = decodeMessage(m);

    if ((_ownerBalance + _partnerBalance) != (stake * 2)) throw;

    address _addr= ecrecover(h, v, r, s);

    if (_addr!=owner && _addr!=partner) throw;

    return true;
  }

  function decodeMessage (string message)
    public constant
    returns (uint256 _nonce, uint256 _player1balance, uint256 _player2balance) {
    var s = message.toSlice();
    var delim = "|".toSlice();

    _nonce = stringToUint(s.split(delim).toString());
    _player1balance = stringToUint(s.split(delim).toString());
    _player2balance = stringToUint(s.split(delim).toString());
  }

  function close (string m, bytes32 h, uint8 v, bytes32 r, bytes32 s) {
    if (msg.sender != owner && msg.sender != partner) throw;

    if (!validateMessage(m, h, v, r, s)) throw;

    var (nonce, ownerBalance, partnerBalance) = decodeMessage(m);

    if (!partner.send(partnerBalance)) throw;

    if (!owner.send(this.balance)) throw;

    ChannelClosed(nonce, ownerBalance, partnerBalance);
  }

  function getBlanace() public constant returns (uint256) {
    return this.balance;
  }

  function signatureSplit (bytes signature) private
    returns (bytes32 r, bytes32 s, uint8 v) {
    // The signature format is a compact form of:
    //   {bytes32 r}{bytes32 s}{uint8 v}
    // Compact means, uint8 is not padded to 32 bytes.
    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))

      // Here we are loading the last 32 bytes, including 31 bytes
      // of 's'. There is no 'mload8' to do this.
      //
      // 'byte' is not working due to the Solidity parser, so lets
      // use the second best option, 'and'
      v := and(mload(add(signature, 65)), 1)
    }

    // old geth sends a `v` value of [0,1], while the new, in line with the YP sends [27,28]
    if(v < 27) v += 27;
  }

  function getTransferRawAddress (bytes memory signed_transfer) internal
    returns (bytes memory, address) {
    uint signature_start;
    uint length;
    bytes memory signature;
    bytes memory transfer_raw;
    bytes32 transfer_hash;
    address transfer_address;

    length = signed_transfer.length;
    signature_start = length - 65;
    signature = slice(signed_transfer, signature_start, length);
    transfer_raw = slice(signed_transfer, 0, signature_start);

    transfer_hash = sha3(transfer_raw);
    var (r, s, v) = signatureSplit(signature);
    transfer_address = ecrecover(transfer_hash, v, r, s);

    return (transfer_raw, transfer_address);
  }

  function slice (bytes a, uint start, uint end) private returns (bytes n) {
    if (a.length < end) {
      throw;
    }

    if (start < 0) {
      throw;
    }

    n = new bytes(end - start);

    // python style slice
    for (uint i = start; i < end; i++) {
      n[i - start] = a[i];
    }
  }

  function stringToUint (string s) constant returns (uint result) {
    bytes memory b = bytes(s);
    uint i;
    result = 0;

    for (i = 0; i < b.length; i++) {
      uint c = uint(b[i]);
      if (c >= 48 && c <= 57) {
        result = result * 10 + (c - 48);
      }
    }
  }

  function verify (bytes32 hash, uint8 v, bytes32 r, bytes32 s) constant
    returns (address retAddr) {
    retAddr = ecrecover(hash, v, r, s);
  }
}

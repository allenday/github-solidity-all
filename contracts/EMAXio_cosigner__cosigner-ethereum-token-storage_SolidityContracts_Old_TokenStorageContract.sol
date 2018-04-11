pragma solidity ^0.4.15;

contract TokenStorageContract {
  uint m_required;
  uint lastNonce;
  uint securityValue;
  bool contractFrozen;

  string public name;
  uint8 public decimals;
  string public symbol;

  uint signers;
  uint numSigners;

  uint m_numOwners;
  address admin;
  uint adminSigned;
  mapping(address => uint) ownerIndex;
  mapping(uint => address) owners;
  address tokenContract;

  uint transactionNonce;
  address sender;
  uint senderSigned;
  bytes32 transactionHash;
  uint numTransactions;
  mapping(uint => Transaction) transactions;

  uint numSignatures;
  mapping(uint => SigData) signatures;

  mapping(address => uint) balances;
  uint totalBalance;

  // Async signatures
  struct PendingState {
    uint yetNeeded;
    uint ownersDone;
    uint senderSigned;
    uint index;
  }

  mapping(bytes32 => Transaction) m_txs;
  mapping(bytes32 => PendingState) m_pending;
  bytes32[] m_pendingIndex;

  // Transaction and signature structures
  struct Transaction {
    address from;
    address to;
    uint value;
  }

  struct SigData {
    uint8 sigV;
    bytes32 sigR;
    bytes32 sigS;
  }

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Deposit(address indexed _from, address indexed _to, uint256 _value);
  event Reconcile(address indexed _affected, int256 _value);
  event Sweep(address indexed _requestor, address indexed _to, uint256 _value);
  event Confirmation(address owner, bytes32 operation);
  event Revoke(address owner, bytes32 operation);
  event MultiTransact(address owner, bytes32 operation, address to, address from, uint value);
  event ConfirmationNeeded(bytes32 operation, address initiator, address to, address from, uint value);

  function calculateTxHash() internal returns(bytes32) {
    transactionHash = 0x00;
    for (uint i = 0; i < numTransactions; i++) {
      transactionHash = sha3(transactionHash, transactions[i].to, transactions[i].value, transactionNonce);
    }

    return transactionHash;
  }

  function calculateHash(address[] hashTransactions, uint[] hashValues) constant returns(bytes32) {
    bytes32 hash = 0x00;
    for (uint i = 0; i < hashTransactions.length; i++) {
      hash = sha3(hash, hashTransactions[i], hashValues[i], lastNonce + 1);
    }

    return hash;
  }

  function calculateAdminTxHash() constant returns(bytes32) {
    transactionHash = sha3(lastNonce + 1, securityValue);
    return transactionHash;
  }

  function confirmTransactionSig() internal returns(bool) {
    if (transactionNonce != lastNonce + 1)
      revert();

    senderSigned = 0;
    adminSigned = 0;
    signers = 0;
    numSigners = 0;
    for (uint i = 0; i < numSignatures && i < 8; i++) {
      address signer = ecrecover(transactionHash, signatures[i].sigV, signatures[i].sigR, signatures[i].sigS);
      uint ownerBit = ownerIndexBit(signer);
      uint ownerValue = 2 ** ownerBit;
      if (ownerBit > 0 && (signers & ownerValue == 0)) {
        signers |= ownerValue;
        numSigners++;
      }
      if (signer == sender) {
        senderSigned = 1;
      }
      if (signer == admin) {
        adminSigned = 1;
      }
    }

    if (numSigners >= m_required) {
      lastNonce = transactionNonce;
      return true;
    }

    revert();
  }

  function confirmTransaction() internal returns(bool) {
    calculateTxHash();
    return confirmTransactionSig();
  }

  function confirmAdminTx(uint nonce) internal returns(bool) {
    transactionNonce = nonce;
    calculateAdminTxHash();
    return (confirmTransactionSig() && adminSigned == 1);
  }

  function ownerIndexBit(address addr) constant returns(uint) {
    return ownerIndex[addr];
  }

  function getNonce() constant returns(uint) {
    return lastNonce + 1;
  }

  function getSecurityValue() constant returns(uint) {
    return securityValue;
  }

  function isOwner(address addr) constant returns(bool) {
    return (ownerIndex[addr] > 0);
  }

  function getOwners() constant returns(address[]) {
    address[] memory ownersList = new address[](m_numOwners);
    for (uint i = 0; i < m_numOwners; i++) {
      ownersList[i] = owners[i + 1];
    }

    return ownersList;
  }

  function min(uint val1, uint val2) internal returns(uint) {
    if (val1 > val2)
      return val2;
    return val1;
  }

  function max(uint val1, uint val2) internal returns(uint) {
    if (val1 > val2)
      return val1;
    return val2;
  }

  function balanceOf(address _owner) constant returns(uint256 balance) {
    if (_owner == admin) {
      TokenContract child = TokenContract(tokenContract);
      return max(0, (child.balanceOf(this) < totalBalance) ? 0 : child.balanceOf(this) - totalBalance) +
        balances[_owner];
    } else {
      return balances[_owner];
    }
  }

  function totalSupply() constant returns(uint256 supply) {
    return totalBalance;
  }

  function TokenStorageContract(address _tokenContract, address _admin, address[] _owners, uint _required, uint _securityValue,
    string _name, string _symbol, uint8 _decimals) {
    lastNonce = 0;
    securityValue = _securityValue;
    totalBalance = 0;
    contractFrozen = false;
    admin = _admin;
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    for (uint i = 0; i < _owners.length; i++) {
      owners[i + 1] = _owners[i];
      ownerIndex[_owners[i]] = i + 1;
    }
    m_numOwners = _owners.length;
    m_required = _required;
    tokenContract = _tokenContract;
  }

  function updateOwners(uint nonce, address _admin, address[] _owners, uint _required,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
    numSignatures = sigV.length;
    for (uint i = 0; i < numSignatures; i++) {
      signatures[i].sigV = sigV[i];
      signatures[i].sigR = sigR[i];
      signatures[i].sigS = sigS[i];
    }
    if (confirmAdminTx(nonce)) {
      admin = _admin;
      for (i = 0; i < _owners.length; i++) {
        owners[i + 1] = _owners[i];
        ownerIndex[_owners[i]] = i + 1;
      }
      m_numOwners = _owners.length;
      m_required = _required;
      clearPending();
    }
  }

  function freezeContract(bool freeze, uint nonce, uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
    numSignatures = sigV.length;
    for (uint i = 0; i < numSignatures; i++) {
      signatures[i].sigV = sigV[i];
      signatures[i].sigR = sigR[i];
      signatures[i].sigS = sigS[i];
    }
    if (confirmAdminTx(nonce) == true) {
      contractFrozen = freeze;
    }
  }

  function deleteContract(uint nonce, uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
    numSignatures = sigV.length;
    for (uint i = 0; i < numSignatures; i++) {
      signatures[i].sigV = sigV[i];
      signatures[i].sigR = sigR[i];
      signatures[i].sigS = sigS[i];
    }
    if (confirmAdminTx(nonce) == true) {
      TokenContract child = TokenContract(tokenContract);
      child.transfer(admin, child.balanceOf(this));
      suicide(admin);
    }
  }

  function deposit(address _to, uint256 _value) external returns(bool) {
    if (contractFrozen) return false;
    TokenContract child = TokenContract(tokenContract);
    if (child.transferFrom(msg.sender, this, _value)) {
      balances[_to] += _value;
      totalBalance += _value;
      Deposit(msg.sender, _to, _value);
      return true;
    } else {
      revert();
    }
  }

  function transfer(uint nonce, address _sender, address[] to, uint[] value,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
    if (contractFrozen) return;
    sender = _sender;
    numTransactions = to.length;
    for (uint i = 0; i < numTransactions; i++) {
      transactions[i].to = to[i];
      transactions[i].value = value[i];
    }
    transactionNonce = nonce;

    numSignatures = sigV.length;
    for (i = 0; i < numSignatures; i++) {
      signatures[i].sigV = sigV[i];
      signatures[i].sigR = sigR[i];
      signatures[i].sigS = sigS[i];
    }

    if (confirmTransaction() && senderSigned == 1) {
      TokenContract child = TokenContract(tokenContract);
      for (i = 0; i < numTransactions; i++) {
        if (balanceOf(sender) >= transactions[i].value) {
          totalBalance -= min(transactions[i].value, balances[sender]);
          balances[sender] -= min(transactions[i].value, balances[sender]);
          if (child.transfer(transactions[i].to, transactions[i].value)) {
            Transfer(sender, transactions[i].to, transactions[i].value);
          } else {
            revert();
          }
        } else {
          revert();
        }
      }
    }
  }

  function revoke(bytes32 _operation) external {
    uint owner = ownerIndex[msg.sender];
    if (owner == 0) return;
    uint ownerIndexBit = 2 ** owner;
    var pending = m_pending[_operation];
    if (pending.ownersDone & ownerIndexBit > 0) {
      pending.yetNeeded++;
      pending.ownersDone -= ownerIndexBit;
      Revoke(msg.sender, _operation);
    }
  }

  function clearPending() internal {
    uint length = m_pendingIndex.length;
    for (uint i = 0; i < length; ++i)
      if (m_pendingIndex[i] != 0)
        delete m_pending[m_pendingIndex[i]];
    delete m_pendingIndex;
  }

  function transfer(address _from, address _to, uint _value) returns(bytes32 _r) {
    if (!isOwner(msg.sender)) return;

    _r = sha3(msg.data, block.number);
    if (!confirm(_r) && m_txs[_r].to == 0) {
      m_txs[_r].from = _from;
      m_txs[_r].to = _to;
      m_txs[_r].value = _value;
      ConfirmationNeeded(_r, msg.sender, _to, _from, _value);
    }
  }

  function transfer(address _to, uint _value) returns(bytes32 _r) {
    return transfer(admin, _to, _value);
  }

  function confirm(bytes32 _h) returns(bool) {
    if (!confirmAndCheck(_h)) return false;

    if (m_txs[_h].to != 0) {
      TokenContract child = TokenContract(tokenContract);
      if (balanceOf(m_txs[_h].from) >= m_txs[_h].value) {
        totalBalance -= min(m_txs[_h].value, balances[m_txs[_h].from]);
        balances[m_txs[_h].from] -= min(m_txs[_h].value, balances[m_txs[_h].from]);
        if (child.transfer(m_txs[_h].to, m_txs[_h].value)) {
          MultiTransact(msg.sender, _h, m_txs[_h].to, m_txs[_h].from, m_txs[_h].value);
          Transfer(m_txs[_h].from, m_txs[_h].to, m_txs[_h].value);
          delete m_txs[_h];
          return true;
        } else {
          revert();
        }
      }
    }
  }

  function confirmAndCheck(bytes32 _operation) internal returns(bool) {
    if (contractFrozen) return false;
    var pending = m_pending[_operation];
    if (msg.sender == m_txs[_operation].from) pending.senderSigned = 1;

    uint owner = ownerIndex[msg.sender];
    if (owner == 0) return false;

    if (pending.yetNeeded == 0) {
      pending.yetNeeded = m_required;
      pending.ownersDone = 0;
      pending.senderSigned = 0;
      pending.index = m_pendingIndex.length++;
      m_pendingIndex[pending.index] = _operation;
      return false;
    }

    uint ownerIndexBit = 2 ** owner;
    if (pending.ownersDone & ownerIndexBit == 0) {
      Confirmation(msg.sender, _operation);
      if (pending.yetNeeded <= 1 && pending.senderSigned == 1) {
        delete m_pendingIndex[m_pending[_operation].index];
        delete m_pending[_operation];
        return true;
      } else if (pending.yetNeeded > 1) {
        pending.yetNeeded--;
        pending.ownersDone |= ownerIndexBit;
      }
    }

    return false;
  }

  function setTokenContract(uint nonce, address _child,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
    numSignatures = sigV.length;
    for (uint i = 0; i < numSignatures; i++) {
      signatures[i].sigV = sigV[i];
      signatures[i].sigR = sigR[i];
      signatures[i].sigS = sigS[i];
    }
    if (confirmAdminTx(nonce)) {
      tokenContract = _child;
    }
  }

  function reconcile(uint nonce, address[] _to, int[] amount,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
    if (contractFrozen) return;
    numSignatures = sigV.length;
    for (uint i = 0; i < numSignatures; i++) {
      signatures[i].sigV = sigV[i];
      signatures[i].sigR = sigR[i];
      signatures[i].sigS = sigS[i];
    }

    if (confirmAdminTx(nonce)) {
      for (i = 0; i < _to.length; i++) {
        if (int(balances[_to[i]]) + amount[i] >= 0) {
          balances[_to[i]] = uint(int(balances[_to[i]]) + amount[i]);
          totalBalance = uint(int(totalBalance) + amount[i]);
          Reconcile(_to[i], amount[i]);
        } else {
          revert();
        }
      }
    }
  }

  function sweep(uint nonce, address _to, uint amount,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
    if (contractFrozen) return;
    numSignatures = sigV.length;
    for (uint i = 0; i < numSignatures; i++) {
      signatures[i].sigV = sigV[i];
      signatures[i].sigR = sigR[i];
      signatures[i].sigS = sigS[i];
    }

    if (confirmAdminTx(nonce)) {
      TokenContract child = TokenContract(tokenContract);
      if (child.transfer(_to, amount)) {
        Sweep(msg.sender, _to, amount);
      } else {
        revert();
      }
    }
  }
}

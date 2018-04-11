pragma solidity ^0.4.15;

contract TokenAdminContract {
  uint m_required;
  uint lastNonce;
  uint securityValue;

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

  // Transaction and signature structures
  struct Transaction {
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
  event Issuance(uint256 _value);
  event Retirement(uint256 _value);

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

  function isOwner(address addr) constant returns(bool) {
    return (ownerIndex[addr] > 0);
  }

  function getNonce() constant returns(uint) {
    return lastNonce + 1;
  }

  function getSecurityValue() constant returns(uint) {
    return securityValue;
  }

  function getOwners() constant returns(address[]) {
    address[] memory ownersList = new address[](m_numOwners);
    for (uint i = 0; i < m_numOwners; i++) {
      ownersList[i] = owners[i + 1];
    }

    return ownersList;
  }

  function balanceOf(address _owner) constant returns(uint256 balance) {
    return balances[_owner];
  }

  function totalSupply() constant returns(uint256 supply) {
    return totalBalance;
  }

  function TokenAdminContract(address _admin, address[] _owners, uint _required, uint _securityValue) {
    lastNonce = 0;
    securityValue = _securityValue;
    totalBalance = 0;
    admin = _admin;
    for (uint i = 0; i < _owners.length; i++) {
      owners[i + 1] = _owners[i];
      ownerIndex[_owners[i]] = i + 1;
    }
    m_numOwners = _owners.length;
    m_required = _required;
  }

  function updateOwners(uint nonce, address _admin, address[] _owners, uint _required,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
    // Must be signed by everyone and the admin.
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
    }
  }

  function deleteContract(uint nonce, address newAdminContract, uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
    // Must be signed by everyone and the admin
    numSignatures = sigV.length;
    for (uint i = 0; i < numSignatures; i++) {
      signatures[i].sigV = sigV[i];
      signatures[i].sigR = sigR[i];
      signatures[i].sigS = sigS[i];
    }
    if (confirmAdminTx(nonce)) {
      TokenContract child = TokenContract(tokenContract);
      child.updateOwner(newAdminContract);
      suicide(admin);
    }
  }

  function deposit(address _from, address _to, uint256 _value) external returns(bool) {
    if (msg.sender != tokenContract) {
      return false;
    } else {
      balances[_to] += _value;
      totalBalance += _value;
      Deposit(_from, _to, _value);
      return true;
    }
  }

  function transfer(uint nonce, address _sender, address[] to, uint[] value,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
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
        if (balances[sender] >= transactions[i].value) {
          balances[sender] -= transactions[i].value;
          totalBalance -= transactions[i].value;
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

  function issueTokens(uint nonce, address _to, uint amount,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
    numSignatures = sigV.length;
    for (uint i = 0; i < numSignatures; i++) {
      signatures[i].sigV = sigV[i];
      signatures[i].sigR = sigR[i];
      signatures[i].sigS = sigS[i];
    }

    if (confirmAdminTx(nonce)) {
      TokenContract child = TokenContract(tokenContract);
      if (child.transfer(_to, amount)) {
        Issuance(amount);
      } else {
        revert();
      }
    }
  }

  function reconcile(uint nonce, address[] _to, int[] amount,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
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

  function destroyTokens(uint nonce, address _from, uint amount,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {

    numSignatures = sigV.length;
    for (uint i = 0; i < numSignatures; i++) {
      signatures[i].sigV = sigV[i];
      signatures[i].sigR = sigR[i];
      signatures[i].sigS = sigS[i];
    }

    if (confirmAdminTx(nonce) && balances[_from] >= amount) {
      balances[_from] -= amount;
      totalBalance -= amount;
      Retirement(amount);
    } else {
      revert();
    }
  }
}

pragma soldity ^0.4.2;
contract multisigwallet {
    uint m_required;
    uint lastNonce;

    uint signers;
    uint numSigners;

    uint m_numOwners;
    mapping(address => uint) ownerIndex;
    mapping(uint => address) owners;

    uint transactionNonce;
    bytes32 transactionHash;
    uint numTransactions;
    mapping(uint => Transaction) transactions;

    uint numSignatures;
    mapping(uint => SigData) signatures;

    address recipient;
    uint amount;
    bytes data;

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

    event Transfer(address _to, address from, uint256 amount);

    function confirmTransaction() internal returns (bool) {
        transactionHash = 0x00;
        for(uint i = 0; i < numTransactions; i++) {
          transactionHash = sha3(transactionHash, transactions[i].to, transactions[i].value, transactionNonce);
        }


        if(transactionNonce != lastNonce + 1)
          return false;

        signers = 0;
        numSigners = 0;
        for (i = 0; i < numSignatures && i < 8; i++) {
          address signer = ecrecover(transactionHash, signatures[i].sigV, signatures[i].sigR, signatures[i].sigS);
          uint ownerBit = ownerIndexBit(signer);
          uint ownerValue = 2**ownerBit;
          if(ownerBit > 0 && (signers & ownerValue == 0)) {
            signers |= ownerValue;
            numSigners++;
          }
        }

        if(numSigners >= m_required) return true;

        return false;
    }

    function ownerIndexBit(address addr) internal returns (uint) {
        return ownerIndex[addr];
    }

    function isOwner(address addr) public returns (bool) {
      return (ownerIndex[addr] > 0);
    }

    function getOwners() public returns (address[]) {
      address[] ownersList;
      ownersList.length = m_numOwners;
      for(uint i = 0; i < m_numOwners; i++) {
        ownersList[i] = owners[i+1];
      }

      return ownersList;
    }

    // constructor is given number of sigs required to do protected "onlymanyowners" transactions
    // as well as the selection of addresses capable of confirming them.
    function multisigwallet(address[] _owners, uint _required) {
        lastNonce = 0;
        for (uint i = 0; i < _owners.length; i++)
        {
            owners[i+1] = _owners[i];
              ownerIndex[_owners[i]] = i+1;
        }
        m_numOwners = _owners.length;
        m_required = _required;
        amount = 0;
    }

    // kills the contract sending everything to `_to`.
    function kill(uint nonce, address[] to, uint[] value,
                   uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
        numTransactions = 1;
        transactions[0].to = to[0];
        transactions[0].value = value[0];
        transactionNonce = nonce;

        numSignatures = sigV.length;
        for(uint i = 0; i < sigV.length && i < 8; i++) {
          signatures[i].sigV = sigV[i];
          signatures[i].sigR = sigR[i];
          signatures[i].sigS = sigS[i];
        }

        if(confirmTransaction()) {
          lastNonce = transactionNonce;
          suicide(transactions[0].to);
         }
    }

    function execute(address _to, uint _value, bytes _data) returns (bytes32 _id) {
        transactionHash = sha3(lastNonce + 1, _to, _value, _data);
        signers = 0;
        numSigners = 0;
        recipient = _to;
        amount = _value;
        data = _data;
        return transactionHash;
    }

    function confirm(bytes32 _id) returns (bool _success) {
        if(_id == transactionHash && amount != 0 && transactionHash == sha3(lastNonce + 1, recipient, amount, data)) {
            uint ownerBit = ownerIndexBit(msg.sender);
            uint ownerValue = 2**ownerBit;
            if(ownerBit > 0 && (signers & ownerValue == 0)) {
                signers |= ownerValue;
                numSigners++;
            } else {
                return false;
            }

            if(numSigners >= m_required) {
                uint sendAmount = amount;
                lastNonce++;
                signers = 0;
                numSigners = 0;
                amount = 0;
                if(!recipient.call(sendAmount)) {
                    throw;
                } else {
                    Transfer(recipient, this, sendAmount);
                }
            }
            return true;
        }
        return false;
    }

    function execute(uint nonce, address[] to, uint[] value,
                      uint8[] sigV, bytes32[] sigR, bytes32[] sigS) external {
        numTransactions = to.length;
        for(uint i = 0; i < numTransactions; i++) {
            transactions[i].to = to[i];
            transactions[i].value = value[i];
        }
        transactionNonce = nonce;
        amount = 0;

      numSignatures = sigV.length;
      for(i = 0; i < numSignatures; i++) {
        signatures[i].sigV = sigV[i];
        signatures[i].sigR = sigR[i];
        signatures[i].sigS = sigS[i];
      }

      if(confirmTransaction()) {
        lastNonce = transactionNonce;
        for(i = 0; i < numTransactions; i++) {
          if(!transactions[i].to.send(transactions[i].value)) {
              // Rollback the tx if there'x a problem executing it.
              throw;
          } else {
              Transfer(transactions[i].to, this, transactions[i].value);
          }
        }
      }
    }

    // deposit
    function () payable {
        Transfer(this, msg.sender, msg.value);
    }
}

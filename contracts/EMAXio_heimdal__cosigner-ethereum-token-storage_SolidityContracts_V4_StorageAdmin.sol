pragma solidity ^0.4.15;

import "OfflineMultiSig.sol";
import "dappsys/erc20/erc20.sol";
import "dappsys/ds-note/note.sol";

contract StorageAdmin is OfflineMultiSig(0x0000000000000000000000000000000000000000,
                                           0x0000000000000000000000000000000000000000,
                                           new address[](0), 0){
   function setTokenContract(address child,
     uint8[] sigV, bytes32[] sigR, bytes32[] sigS) note external {
     _numSignatures = sigV.length;
     for (uint i = 0; i < _numSignatures; i++) {
       _signatures[i].sigV = sigV[i];
       _signatures[i].sigR = sigR[i];
       _signatures[i].sigS = sigS[i];
     }
     assert(confirmAdminTx());
     _tokenContract = child;
   }

   // Cannot use note here, blows the stack.
   function reconcile(address[] to, int[] amount,
     uint8[] sigV, bytes32[] sigR, bytes32[] sigS) freezable external {
     _numSignatures = sigV.length;
     for (uint i = 0; i < _numSignatures; i++) {
       _signatures[i].sigV = sigV[i];
       _signatures[i].sigR = sigR[i];
       _signatures[i].sigS = sigS[i];
     }

     assert(confirmAdminTx());
     for (i = 0; i < to.length; i++) {
       assert(int(_balances[to[i]]) + amount[i] >= 0);
       _balances[to[i]] = uint(int(_balances[to[i]]) + amount[i]);
       _supply = uint(int(_supply) + amount[i]);
       Reconcile(to[i], amount[i]);
     }
   }

   function deleteContract(uint8[] sigV, bytes32[] sigR, bytes32[] sigS) note external {
     _numSignatures = sigV.length;
     for (uint i = 0; i < _numSignatures; i++) {
       _signatures[i].sigV = sigV[i];
       _signatures[i].sigR = sigR[i];
       _signatures[i].sigS = sigS[i];
     }
     assert(confirmAdminTx());
   }

   function updateOwners(address admin, address[] owners, uint required,
     uint8[] sigV, bytes32[] sigR, bytes32[] sigS) note external {
     _numSignatures = sigV.length;
     for (uint i = 0; i < _numSignatures; i++) {
       _signatures[i].sigV = sigV[i];
       _signatures[i].sigR = sigR[i];
       _signatures[i].sigS = sigS[i];
     }
     assert(confirmAdminTx());
     _admin = admin;
     for (i = 0; i < owners.length; i++) {
       _owners[i + 1] = owners[i];
       _ownerIndex[owners[i]] = i + 1;
     }
     _numOwners = owners.length;
     _required = required;
   }

   function sweep(address to, uint amount,
     uint8[] sigV, bytes32[] sigR, bytes32[] sigS) note freezable external {
     _numSignatures = sigV.length;
     for (uint i = 0; i < _numSignatures; i++) {
       _signatures[i].sigV = sigV[i];
       _signatures[i].sigR = sigR[i];
       _signatures[i].sigS = sigS[i];
     }

     assert(confirmAdminTx());
   }
}

pragma solidity ^0.4.8;

import "./MultiSigWalletFactory.sol";

contract WingsMultisigFactory is MultiSigWalletFactory {
  address[] public accounts;
  address public multisig;

  function addAddress(address account) {
    accounts.push(account);
  }

  function create(uint required) {
    multisig = super.create(accounts, required);
  }
}

pragma solidity ^0.4.19;

contract RegisterDrupal {

  // Mapping that matches Drupal generated hash with Ethereum Account address.
  mapping (bytes32 => address) _accounts;

  address _registryAdmin;

  // Allowed to administrate accounts only, not everything
  address _accountAdmin;

  // If a newer version of this registry is available, force users to use it
  bool _registrationDisabled;

  // Event allowing listening to newly signed Accounts (?)
  event AccountCreatedEvent (address indexed from, bytes32 indexed hash, int error);

  function accountCreated(address from, bytes32 hash, int error) public {
    AccountCreatedEvent(from, hash, error);
  }

  // Register Account
  function newUser(bytes32 drupalUserHash) public {

    if (_accounts[drupalUserHash] == msg.sender) {
      // Hash allready registered to address.
      accountCreated(msg.sender, drupalUserHash, 4);
    }
    else if (_accounts[drupalUserHash] > 0) {
      // Hash allready registered to different address.
      accountCreated(msg.sender, drupalUserHash, 3);
    }
     else if (drupalUserHash.length > 32) {
      // Hash too long
      accountCreated(msg.sender, drupalUserHash, 2);
    }
    else if (_registrationDisabled){
      // Registry is disabled because a newer version is available
      accountCreated(msg.sender, drupalUserHash, 1);
    }
    else {
      _accounts[drupalUserHash] = msg.sender;
      accountCreated(msg.sender, drupalUserHash, 0);
    }
  }

  // Validate Account
  function validateUserByHash (bytes32 drupalUserHash) public constant returns (address result) {
      return _accounts[drupalUserHash];
  }

  function contractExists () public pure returns (bool result){
    return true;
  }

  // Administrative below
  function RegisterDrupal() public {
    _registryAdmin = msg.sender;
    _accountAdmin = msg.sender; // can be changed later
    _registrationDisabled = false;
  }

  function adminSetRegistrationDisabled(bool registrationDisabled) public {
    // currently, the code of the registry can not be updated once it is
    // deployed. if a newer version of the registry is available, account
    // registration can be disabled
    if (msg.sender == _registryAdmin) {
      _registrationDisabled = registrationDisabled;
    }
  }

  function adminSetAccountAdministrator(address accountAdmin) public {
    if (msg.sender == _registryAdmin) {
      _accountAdmin = accountAdmin;
    }
  }

  function adminRetrieveDonations() public {
    if (msg.sender == _registryAdmin) {
      _registryAdmin.transfer(this.balance);
    }
  }

  function adminDeleteRegistry() public {
    if (msg.sender == _registryAdmin) {
      selfdestruct(_registryAdmin); // this is a predefined function, it deletes the contract and returns all funds to the admin's address
    }
  }

}

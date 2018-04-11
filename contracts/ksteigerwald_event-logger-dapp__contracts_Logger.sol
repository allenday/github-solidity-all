pragma solidity ^0.4.13;

contract Logger {

  address public owner;
  uint public logged;
  string public ipfsHash;

  event Logging(address _from, string _ipfsHash, uint _logged);

  modifier isValidIPFS(bool isValid) {
    if (!isValid) {
      revert();
    } else {
      _;
    }
  }

  function getLastHash() constant returns (string) {
    return ipfsHash;
  }

  function logEvent(string _ipfsHash, bool isValid) isValidIPFS(isValid) {
    if (!isValid) {
      revert();
    }

    ipfsHash = _ipfsHash;
    Logging(msg.sender, ipfsHash, now);
  }

  function Logger(string _ipfsHash, bool isValid) isValidIPFS(isValid) {
    owner = msg.sender;
    ipfsHash = _ipfsHash;
    logged = now;
  }



 function disable() {
   if (msg.sender != owner) {
     revert();
   }

   selfdestruct(owner);
 }

}

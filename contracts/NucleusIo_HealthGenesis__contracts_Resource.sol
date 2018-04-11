pragma solidity ^0.4.2;

contract Resource {

  // The account that created this resource
  address public owner;

  // Base URL to a resource
  string public url;

  // The address of the recipient who has access to the resource.  The recipient
  // can access the resource by signing the request using web3.eth.sign().
  // The resource server can validate the signature to ensure the
  // recipient owns the private key.
  address public recipient;

  // an identifier that can be used to group multiple resource smart contracts
  // together.  In the case of DICOM, it could be the study instance uid
  string public resourceId;

  // the type of resource (e.g. wadouri, wadors)
  string public resourceType;

  // Event that is fired every time a resoruce smart contract is created.
  // Needed to reliably find resource smart contracts
  event ResourceCreated(address indexed recipient);

  function Resource(address _recipient, string _url, string _resourceId, string _resourceType) {
    owner = msg.sender;
    recipient = _recipient;
    url = _url;
    resourceId = _resourceId;
    resourceType = _resourceType;
    ResourceCreated(recipient);
  }

}

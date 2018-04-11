pragma solidity ^0.4.17;


contract EndpointRegistryContract {

  // EVENTS

  event AddressRegistered(address ethAddress, string socket);

  // PUBLIC FUNCTIONS

  /*
    * @notice Registers the Ethereum Address to the Endpoint socket.
    * @dev Registers the Ethereum Address to the Endpoint socket.
    * @param string of socket in this format "127.0.0.1:40001"
    */
  function registerEndpoint(string socket) public noEmptyString(socket) {
    string storage oldSocket = sockets[msg.sender];

    // Compare if the new socket matches the old one, if it does just return
    if (equals(oldSocket, socket)) {
        return;
    }

    // Put the ethereum address 0 in front of the oldSocket,old_socket:0x0
    sockets[msg.sender] = socket;
    AddressRegistered(msg.sender, socket);
  }

  /*
    * @notice Finds the socket if given an Ethereum Address
    * @dev Finds the socket if given an Ethereum Address
    * @param An eth_address which is a 20 byte Ethereum Address
    * @return A socket which the current Ethereum Address is using.
    */
  function findEndpointByAddress(address ethAddress) public view returns (string socket) {
      return sockets[ethAddress];
  }

  // INTERNAL FUNCTIONS

  function equals(string a, string b) internal pure returns (bool result) {
    return keccak256(a) == keccak256(b);
  }

  // MODIFIERS

  modifier noEmptyString(string str) {
    require(equals(str, "") != true);
    _;
  }

  // FIELDS

  // Mapping of Ethereum Addresses => SocketEndpoints
  mapping(address => string) sockets;
}

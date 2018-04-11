pragma solidity ^0.4.6;

contract PayingBackContract {
  address public organizer;

  function PayingBackContract() payable {
    organizer = msg.sender;
  }

  function destroy() {
    if (msg.sender == organizer) {
      suicide(organizer);
    }
  }
}

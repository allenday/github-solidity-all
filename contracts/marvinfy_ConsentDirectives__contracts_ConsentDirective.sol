pragma solidity ^0.4.4;

contract ConsentDirective {

  // To whom the Patient is giving consent
  address public Who; 
  function SetWho(address who) { Who = who; }
  function GetTheWho() constant returns (address) { return Who; }

  // The semantics of the What are specified by the system administrator
  // All bits except the four least significant bits are of general purpose
  //
  // Four LSBs:
  // Bit 0: authority to consent on the patient's behalf
  // Bit 1: specific record -- this instance represents the consent directives of a specific medical record
  // Bit 2: reserved
  // Bit 3: reserved
  //
  // TODO refactor uint256 (consent data) to its own type (ConsentData contract)
  uint256 public What;
  function SetWhat(uint256 what) { What = what; }

  // Specific record that this instance represents
  // Null when non-specific
  address public Record;
  function SetRecord(address record) { Record = record; }

  // TODO add expiry date

  function ConsentDirective(address who, uint256 what) {
    Who = who;
    What = what;
    Record = address(0);
  }

  function HasDelegateAuthority() constant returns(bool) {
    return (What & 0x1 == 0x1);
  }
}

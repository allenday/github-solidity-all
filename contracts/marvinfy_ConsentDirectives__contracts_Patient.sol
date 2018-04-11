pragma solidity ^0.4.4;

import "./Category.sol";
import "./ConsentDirective.sol";

contract Patient {
  
  address public Owner;

  ConsentDirective[] public Directives;

  function Patient(address owner) {
    Owner = owner;
  }

  function GetOwner() constant returns(address) {
    return Owner;
  }

  function GetConsentDirectiveCount() constant returns(uint) {
    return Directives.length;
  }

  function GetConsentDirective(uint i) constant returns(ConsentDirective) {
    return Directives[i];
  } 

  function GetConsentDirectives() constant returns(ConsentDirective[]) {
    return Directives;
  }

  function AddConsentDirective(ConsentDirective cd) {
    if (this.HasDelegatedAuthority(msg.sender, cd)) {
      Directives.push(cd);
    }
  }

  function RemoveAllConsentDirectives() {
    if (msg.sender == Owner) {
      Directives = new ConsentDirective[](0);
    } else {
      revert();
    }
  }

  //
  // Does Patient consent WHO to do WHAT?
  //
  function ConsentsTo(address who, Category what) constant returns(bool) {
    // Owner always consents to themself
    if (who == Owner) {
      return true;
    }

    for (uint i = 0; i < Directives.length; i++) {

      if (who != Directives[i].Who()) {
        continue;
      }

      var dir_data = Directives[i].What();   // Directive data (consented)

      for (uint j = 0; j < what.GetConsentDataCount(); j++) {
        var cat_data = what.GetConsentData(j); // Requested data (category)

        var res_data = dir_data & cat_data; 
        if (res_data == cat_data) {
          return true;
        }
      }

    }

    return false;
  }

  // Has Patient delegated authority to WHO to consent to WHAT on their behalf?
  function HasDelegatedAuthority(address who, ConsentDirective what) constant returns(bool) {

    // Owner always has authority to consent
    if (who == Owner) {
      return true;
    }

    // The least significant bit indicates authority to consent on the Patient's behalf,
    // therefore we change the LSB to 1 to check for authority to consent.
    var req_data = what.What() | 0x1;

    for (uint i = 0; i < Directives.length; i++) {
      var con_data = Directives[i].What(); // Consented data

      // req_data 0001 0001 
      // con_data 0111 0001 &
      // res_data 0001 0001 (result)
      if (req_data & con_data == req_data) {
        return true;
      }

    }

    return false;
  }

}

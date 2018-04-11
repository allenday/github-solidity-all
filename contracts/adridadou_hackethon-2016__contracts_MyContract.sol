contract EntitlementRegistry{
  function get(string _name)constant returns(address );
  function getOrThrow(string _name)constant returns(address );
}

contract Entitlement{
  function isEntitled(address _address)constant returns(bool );
}

contract MyContract {

  // BlockOne ID bindings

  // The address below is for the Edgware network only
  EntitlementRegistry entitlementRegistry = EntitlementRegistry(0xe5483c010d0f50ac93a341ef5428244c84043b54);

  function getEntitlement() constant returns(address) {
      return entitlementRegistry.getOrThrow("pubcrawl");
  }

  modifier entitledUsersOnly {
    if (!Entitlement(getEntitlement()).isEntitled(msg.sender)) throw;
    _
  }

  // Your implementation goes here

}
    
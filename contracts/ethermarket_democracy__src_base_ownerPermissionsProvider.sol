// #include_once "base/owned.sol"

contract OwnedPermissionsProvider is Owned {
    function permitted(address action) returns (bool result) {
        return owner == msg.sender;
    }
}

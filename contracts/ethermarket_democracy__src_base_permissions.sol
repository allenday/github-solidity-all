contract PermissionsEnabled {
    function getPermissionsProvider() returns (address result);
    function setPermissionsProvider(address provider) returns (bool result);
}

contract PermissionsProvider {
    function permitted(address action) returns (bool result);
}

// #include_once "base/permissions.sol"
// #include_once "base/ownedApiEnabled.sol"

contract ProtectedContract is OwnedApiEnabled, PermissionsEnabled {
    function apiAuthorized() returns (bool result) {
        return super.apiAuthorized() || permittedSender();
    }

    function setApiAddress(address newApi) returns (bool result) {
        if (PermissionsEnabled(newApi).getPermissionsProvider() == 0x0) return false;
        return super.setApiAddress(newApi);
    }

    function getPermissionsProvider() returns (address result) {
        return PermissionsEnabled(api).getPermissionsProvider();
    }

    function setPermissionsProvider(address provider) returns (bool result) {
        return PermissionsEnabled(api).setPermissionsProvider(provider);
    }

    function permittedSender() returns (bool result) {
        if (api == 0x0) return false;
        return PermissionsProvider(PermissionsEnabled(api).getPermissionsProvider()).permitted(msg.sender);
    }
}

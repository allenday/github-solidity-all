// #include_once "base/owned.sol"
// #include_once "base/api.sol"

contract OwnedApiEnabled is Owned, ApiEnabled {
    address api;

    function apiAuthorized() returns (bool result) {
       return ((api == 0x0 && msg.sender == owner) || msg.sender == api);
    }

    function setApiAddress(address newApi) returns (bool result) {
        if (!apiAuthorized()) return false;
        api = newApi;
        return true;
    }

    function remove() returns (bool result) {
        if (!apiAuthorized()) return false;
        if (api == 0x0) {
            suicide(owner);
        } else {
            suicide(api);
        }
        return true;
    }
}

contract ApiProvider {
    function contracts(string32 name) returns (address addr) {}
    function addContract(string32, address newContract) returns (bool result) {}
    function removeContract(string32) returns (bool result) {}
}

contract ApiEnabled {
    function apiAuthorized() returns (bool result) {}
    function setApiAddress(address newApi) returns (bool result) {}
    function remove() {}
}

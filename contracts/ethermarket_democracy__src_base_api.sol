contract ApiProvider {
    mapping (bytes32 => address) public contracts;
    function addContract(bytes32, address newContract) returns (bool result);
    function removeContract(bytes32) returns (bool result);
}

contract ApiEnabled {
    function apiAuthorized() returns (bool result);
    function setApiAddress(address newApi) returns (bool result);
    function remove() returns (bool result);
}

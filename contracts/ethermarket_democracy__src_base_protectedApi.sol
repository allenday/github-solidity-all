// #include_once "base/api.sol"
// #include_once "base/permissions.sol"

contract ProtectedApi is ApiProvider, PermissionsEnabled {
    // PoC-8

    bytes32 PERMISSIONS_CONTRACT = "PermissionsProvider";

    mapping (uint => bytes32) contractNames;
    uint contractCount;

    function ProtectedApi(address permissionsProvider) {
        contracts[PERMISSIONS_CONTRACT] = permissionsProvider;
        contractNames[0] = PERMISSIONS_CONTRACT;
        contractCount = 1;
    }

    function getPermissionsProvider() returns (address result) {
        return contracts[PERMISSIONS_CONTRACT];
    }

    function setPermissionsProvider(address provider) returns (bool result) {
        if (!_permitted()) return false;
        contracts[PERMISSIONS_CONTRACT] = provider;
    }

    function addContract(bytes32 name, address newContract) returns (bool result) {
        if (!_permitted()) return;
    
        ApiEnabled contractObj = ApiEnabled(newContract);

        if (!contractObj.setApiAddress(address(this))) {
            return false;
        }
        contracts[name] = newContract;
        contractCount += 1;
        contractNames[contractCount] = name;
        return true;
    }

    function removeContract(bytes32 name) returns (bool result) {
        if (contracts[name] == 0x0 || !_permitted()) return false;
        
        bool match = false;
        for (uint i=0; i < contractCount; i+=1) {
            match = match || (name == contractNames[i]);
            if (match) {
                contractNames[i] = contractNames[i+1];
            }
        }
        ApiEnabled(contracts[name]).remove();
        contracts[name] = 0x0;
        contractCount -= 1;
        return true;
    }

    function remove() {
        if (!_permitted()) return;
        
        for (uint i=1; i < contractCount; i+=1) { // Skip PermissionsProvider contract.
            ApiEnabled(contracts[contractNames[i]]).remove();
        }
        suicide(contracts[PERMISSIONS_CONTRACT]);
    }

    function _permitted() private returns (bool result) {
        return PermissionsProvider(getPermissionsProvider()).permitted(msg.sender);
    }
}

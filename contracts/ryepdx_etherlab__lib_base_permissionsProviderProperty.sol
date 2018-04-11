// #include_once "base/persistentProtectedContract.sol"

contract PermissionsProviderProperty is PersistentProtectedContract {
    function senderIsProvider() returns (bool result) {
        var provider = getPermissionsProvider();
        return (provider != 0x0 && msg.sender == provider);
    }
}

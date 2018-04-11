// #include_once "base/protectedContract.sol"

contract PersistentProtectedContract is ProtectedContract {
    function remove() returns (bool result) {
        if (!permittedSender()) return false;
        return super.remove();
    }
}

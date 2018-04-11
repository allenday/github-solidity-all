// #include_once "base/protectedContract.sol"

contract PersistentProtectedContract is ProtectedContract {
    function remove() {
        if (!permittedSender()) return;
        super.remove();
    }
}

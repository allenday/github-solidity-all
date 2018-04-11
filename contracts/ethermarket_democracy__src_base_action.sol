// #include_once "base/owned.sol"

contract Action is Owned {
    function execute() returns (bool result) {
        if (msg.sender != owner) return false;
        return _execute();
    }

    function remove() returns (bool result) {
        if (msg.sender != owner) return false;
        suicide(owner);
        return true;
    }

    function _execute() private returns (bool result);
}

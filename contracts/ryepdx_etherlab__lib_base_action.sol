// #include_once "base/owned.sol"

contract Action is Owned {
    function execute() {
        if (msg.sender != owner) return;
        _execute();
    }

    function remove() {
        if (msg.sender != owner) return;
        suicide(owner);
    }

    function _execute() private {
        // Override this in your extending class with your own code.
    }
}

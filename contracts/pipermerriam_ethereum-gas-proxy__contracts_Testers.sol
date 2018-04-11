contract GasProxyTester {
    bool public flag;

    function doit() {
        flag = true;
    }

    function undo() {
        flag = false;
    }

    uint public value;

    function set(uint v) {
        value = v;
    }

    function infinite() {
        while (true) {
            address(this).send(1);
        }
    }

    function fails() {
        throw;
    }

    function variable(uint loops) {
        for (uint i = 0; i < loops; i++) {
            address(this).send(1);
        }
    }

    function() {
    }
}

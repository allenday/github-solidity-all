import "libraries/GasProxyLib.sol";


contract GasProxy {
        address public __owner;
        address public __target;

        function GasProxy(address _owner, address _target) {
                __owner = _owner;
                __target = _target;
        }

        modifier onlyowner { if (tx.origin == __owner) _ }

        function() public onlyowner {
                uint startGas = msg.gas;

                GasProxyLib.invoke(startGas, __owner, __target, msg.data);
        }

        function __kill() public onlyowner {
                suicide(__owner);
        }
}

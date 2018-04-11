library GasProxyLib {
        uint constant GAS_OVERHEAD = 9642;
        //uint constant EXTRA_CALL_GAS = 28670;
        uint constant EXTRA_CALL_GAS = 28619;

        function invoke(uint startGas, address sender, address target, bytes callData) {
                if (callData.length > 0) {
                        //target.call(callData);
                        if (!target.call.gas(msg.gas - GAS_OVERHEAD)(callData)) {
                                startGas -= 128;
                        }
                        uint cost = (startGas - msg.gas + EXTRA_CALL_GAS) * tx.gasprice;
                        if (cost > address(this).balance) {
                                cost = address(this).balance;
                        }
                        if (cost > 0) {
                                sender.send(cost);
                        }
                }
        }
}

import "StateChannel";

contract PaymentChannel is StateChannel {
    function PaymentChannel(address addressA, address addressB, uint timeout, bytes state)
        StateChannel(addressA, addressB, timeout, state) {}

    function bytesToUint(bytes input) constant returns (uint returned) {
        for (uint i = 0; i < input.length; i++) {
            returned |= uint8(input[i]) * 2**(i * 8);
        }
    }

    function checkState(bytes state) constant returns (bool) {
        return bytesToUint(state) <= this.balance;
    }

    function finaliseState() {
        _addressA.send(bytesToUint(_state));
        _addressB.send(this.balance);
    }
}

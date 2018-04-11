contract StateChannel {

    event ContractClosing(address sender, uint nonce, bytes state);
    event ContractClosed(address sender, bytes state);

    address _addressA;
    address _addressB;
    uint _timeout;
    bytes _state;
    uint _nonce = 0;
    uint _lastTimestamp = 0;
    bool aFinalised = false;
    bool bFinalised = false;

    function checkState(bytes state) constant internal returns (bool);
    function finaliseState() internal;

    function StateChannel(address addressA, address addressB, uint timeout, bytes state) {
        _addressA = addressA;
        _addressB = addressB;
        _timeout = timeout;
        _state = state;
    }

    function getHash(bytes state, uint nonce) constant returns (bytes32) {
        return sha3(state, nonce);
    }

    function closeChannel(bytes state, uint nonce, uint8 v, bytes32 r, bytes32 s) external returns (bool) {
        if (_nonce >= nonce || !checkState(state)) {
            return false;
        }

        if ((msg.sender == _addressA && ecrecover(getHash(state, nonce), v, r, s) == _addressB) ||
            (msg.sender == _addressB && ecrecover(getHash(state, nonce), v, r, s) == _addressA)) {
            ContractClosing(msg.sender, nonce, state);
            _state = state;
            _nonce = nonce;
            _lastTimestamp = now;
            aFinalised = false;
            bFinalised = false;
            return true;
        } else {
            return false;
        }
    }

    function finaliseChannel() external returns (bool) {
        if ((aFinalised && bFinalised) || (_lastTimestamp > 0 && _lastTimestamp + _timeout < now)) {
            finaliseState();
            ContractClosed(msg.sender, _state);
            selfdestruct(msg.sender);
            return true;
        } else {
            aFinalised = aFinalised || msg.sender == _addressA;
            bFinalised = bFinalised || msg.sender == _addressB;
            return false;
        }
    }
}

pragma solidity ^0.4.2;

contract Utils {
    function transferUniqueId(bytes32 _id) internal constant returns (bytes32) {
        return sha3(sha3(this), _id);
    }

    function recoverAddress(bytes32 _hash, bytes _sign) internal constant returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (_sign.length != 65) throw;

        assembly {
            r := mload(add(_sign, 32))
            s := mload(add(_sign, 64))
            v := byte(0, mload(add(_sign, 96)))
        }

        if (v < 27) v += 27;
        if (v != 27 && v != 28) throw;

        address recAddr = ecrecover(_hash, v, r, s);
        if (recAddr == 0) throw;
        return recAddr;
    }
}
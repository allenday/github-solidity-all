pragma solidity ^0.4.16;

library HelperMethods {
  function proposalData(string _functionSig, address _destination, uint _value, bytes _calldata) internal constant returns (bytes) {
    bytes4 functionID;

    if(bytes(_functionSig).length == 0) {
      functionID = bytes4(0);
    } else {
      functionID = bytes4(sha3(_functionSig));
    }

    bytes memory data;

    assembly {
      let mc := data

      //leave space for the length later
      mc := add(mc, 0x20)

      mstore(mc, mul(0xd7f31eb9, 0x100000000000000000000000000000000000000000000000000000000))
      mc := add(mc, 4)

      mstore(mc, _destination)
      mc := add(mc, 0x20)

      mstore(mc, _value)
      mc := add(mc, 0x20)

      switch iszero(functionID)
      case 0 {
        mstore(mc, mul(functionID, 0x100000000000000000000000000000000000000000000000000000000))
        mc := add(mc, 4)
      }

      let cdlength := mload(_calldata)
      _calldata := add(_calldata, 0x20)

      cdlength := add(mc, cdlength)

      for {} lt(mc, cdlength) {
        mc := add(mc, 0x20)
        _calldata := add(_calldata, 0x20)
      } {
        mstore(mc, mload(_calldata))
      }

      // set the length
      mstore(data, sub(mc, add(data, 0x20)))
      mstore(add(data, 0x20), sub(mc, data))

      // set the free-memory pointer to the right address
      mstore(0x40, mc)
    }

    return data;
  }

  function bytes32ToBytes(bytes32[] _bytes32Array) internal constant returns (bytes) {
    assembly {
      let length := mul(mload(_bytes32Array), 0x20)

      mstore(sub(_bytes32Array, 0x20), 0x20)
      mstore(_bytes32Array, length)

      return(sub(_bytes32Array, 0x20), add(length, 0x40))
    }
  }

  function concatBytes(bytes _preBytes, bytes _postBytes) internal constant returns (bytes) {
    assembly {
      let mc := mload(_preBytes)
      let postlength := mload(_postBytes)
      mstore(_preBytes, add(postlength, mc))

      mc := add(mc, _preBytes)

      for {} lt(_postBytes, postlength) {
        mc := add(mc, 0x20)
        _postBytes := add(_postBytes, 0x20)
      } {
        mstore(mc, mload(_postBytes))
      }
    }

    return _preBytes;
  }
}

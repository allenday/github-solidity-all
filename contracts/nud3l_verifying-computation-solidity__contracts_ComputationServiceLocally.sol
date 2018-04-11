pragma solidity ^0.4.8;
import "./usingOraclize.sol";
import "./AbstractArbiter.sol";

contract ComputationServiceLocally {
  bool public correctComputation;

  struct Request {
    string input1;
    string input2;
    uint operation;
    string result;
    address arbiter;
  }

  mapping(uint256 => Request) public requestId;

  address public arbiter;

  event newResult(string comp_result);
  event newIndex(uint val1, uint val2);

  function __callback(bytes32 _oraclizeID, string _result) {
    // Nothing implemented here
  }

  function compute(string _val1, string _val2, uint _operation, uint256 _computationId) payable {
    string memory resultString;
    bytes32 resultBytes;
    uint resultInt;
    uint val1;
    uint val2;

    val1 = stringToUint(_val1);
    val2 = stringToUint(_val2);

    if (correctComputation) {
      resultInt = val1 * val2;
    } else {
      resultInt = val1 * val2 + 5;
    }

    resultBytes = uintToBytes(resultInt);

    // store address for specific request
    requestId[_computationId].input1 = _val1;
    requestId[_computationId].input2 = _val2;
    requestId[_computationId].operation = _operation;
    requestId[_computationId].arbiter = msg.sender;
    requestId[_computationId].result = bytes32ToString(resultBytes);

    newResult(requestId[_computationId].result);

    // send result to arbiter contract
    AbstractArbiter myArbiter = AbstractArbiter(requestId[_computationId].arbiter);
    myArbiter.receiveResults.gas(300000)(requestId[_computationId].result, _computationId);
  }

  function provideIndex(string _resultSolver, uint _computationId) {
    // this is for two intergers: always returns 0 and 1 for two two intergers
    // Request memory _request = requestId[_computationId];

    AbstractArbiter myArbiter = AbstractArbiter(msg.sender);
    myArbiter.receiveIndex(0, 1, 0, _computationId, true);
    newIndex(0,1);
  }

  function registerOperation(uint _operation, string _query) {
    // operation 0: add two integers
    if (_operation == 0) {
      correctComputation = true;
    } else {
      correctComputation = false;
    }
  }

  function enableArbiter(address _arbiterAddress) {
    arbiter = _arbiterAddress;
    AbstractArbiter myArbiter = AbstractArbiter(_arbiterAddress);
    myArbiter.enableService();
  }

  function disableArbiter(address _arbiterAddress) {
    delete arbiter;
    AbstractArbiter myArbiter = AbstractArbiter(_arbiterAddress);
    myArbiter.disableService();
  }

  function getResult(uint _computationId) constant returns (string) {
    return requestId[_computationId].result;
  }

  function stringToUint(string s) internal constant returns (uint result) {
    bytes memory b = bytes(s);
    uint i;
    result = 0;
    for (i = 0; i < b.length; i++) {
      uint c = uint(b[i]);
      if (c >= 48 && c <= 57) {
          result = result * 10 + (c - 48);
      }
    }
  }

  function uintToBytes(uint v) constant internal returns (bytes32 ret) {
    if (v == 0) {
        ret = '0';
    }
    else {
        while (v > 0) {
            ret = bytes32(uint(ret) / (2 ** 8));
            ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
            v /= 10;
        }
    }
    return ret;
  }

  function bytes32ToString(bytes32 x) constant returns (string) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
  }
}

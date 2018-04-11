pragma solidity ^0.4.8;

contract Judge {
  function resolveDispute(uint _input1, uint _input2, uint _result, uint _operation) returns (bool check) {
    uint check_result;

    if (_operation == 0) {
      check_result = _input1 * _input2;
      if (check_result == _result) check = true;
    }
    else if (_operation == 1) {
      check_result = _input1 + _input2;
      if (check_result == _result) check = true;
    }
    else if (_operation== 2) {
      check_result = _input1 - _input2;
      if (check_result == _result) check = true;
    }
    return check;
  }
}

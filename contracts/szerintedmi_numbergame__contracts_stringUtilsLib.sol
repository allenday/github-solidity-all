pragma solidity ^0.4.8;

library stringUtilsLib {

  function stringToUint(string s) constant returns (uint result) {
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

    /* alternative for stringToUint
    // Copyright (c) 2015-2016 Oraclize srl, Thomas Bertani
    function parseInt(string _a, uint _b) internal returns (uint) {
      bytes memory bresult = bytes(_a);
      uint mint = 0;
      bool decimals = false;
      for (uint i = 0; i < bresult.length; i++) {
        if ((bresult[i] >= 48) && (bresult[i] <= 57)) {
          if (decimals) {
            if (_b == 0) break;
              else _b--;
          }
          mint *= 10;
          mint += uint(bresult[i]) - 48;
        } else if (bresult[i] == 46) decimals = true;
      }
      return mint;
    } */
} // strings

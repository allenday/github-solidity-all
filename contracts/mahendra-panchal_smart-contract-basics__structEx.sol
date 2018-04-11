pragma solidity ^0.4.4;

/** @title structEx 
*   event log example
*/
contract structEx {
    
    uint    a;
    uint8   b = 255; // 8 means   0000 0000
    uint16  c = 256; // 9 means 1 0000 0000
    uint32  d;
    uint40  e;
    
  struct student {
      uint rollNumber;
      string name;
      uint contactNo;
      bool isGraduate;
  }
  
}
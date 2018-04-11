pragma solidity ^0.4.4;

contract SpecialArrays {
  function SpecialArrays() {
    // constructor
  }

  byte[3] staticBytes = [byte(1),2,3] ;
  //bytes3 staticBytes= bytes3("hi");

  bytes dynamicBytes;
  string items = "hello" ;

  function getCharAt(uint index) returns (byte) {
    bytes memory itemsinbytes = bytes(items);
    return itemsinbytes[index];
  }

  function getFirstAndSecondItem() returns (byte first,byte second) {
    bytes memory itemsinbytes = bytes(items);
    first = itemsinbytes[0];
    second = itemsinbytes[1];
  }


  function getStaticArraySize() returns (uint length) {
    length = staticBytes.length;
  }

  function getStaticElementAt(uint index) returns (byte) {
     return staticBytes[index];
  }

  function addNumberToDynamicBytes(uint number) {
    dynamicBytes.push(byte(number));
  }

  function getDynamicElementAt(uint index) returns (byte value) {
    value = dynamicBytes[index];  
  }

}

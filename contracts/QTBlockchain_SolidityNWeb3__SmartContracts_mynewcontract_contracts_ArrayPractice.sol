pragma solidity ^0.4.4;

contract ArrayPractice {
  function ArrayPractice() {
    // constructor
    

  }
  int8[] dynItems;
  int8[3] staticItems = [int8(1),2,3];

  function staticArrayTests() returns(int sum) {
    // Uninitialized storage pointer. Did you mean '<type> memory items'
    //int[2] items;
    //right way to do it 
    int[3] memory items = [int(1), int(2), int(0)];
    //push will not be available for memory array
    //items.push(1);
    sum = items[0]+items[1]+items[2];
    return sum;

  }

  function staticArrayChangeValue(int8 value,uint position) {
    staticItems[position] = value;
  }

  function getStaticArraySum() returns (int sum) {
     sum = staticItems[0]+staticItems[1]+staticItems[2];
  }

  function getStaticArray() returns (int8[3] items) {
    return staticItems;
  }


  function setDynamicArraySize(uint size) {
    dynItems = new int8[](size);  
    /*if (dynItems.length==0) {
      dynItems= new int8[](size);  
    } else {
    }*/
  }

  function getDynamicArraySize() returns (uint) {
    return dynItems.length;
  }

  function setDynamicArrayElement(int8 value,uint position) {
    dynItems[position] = value;
  }

  function getDynamicArrayElement(uint index) returns (int8) {
    return dynItems[index];
  }


}

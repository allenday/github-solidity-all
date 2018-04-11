pragma solidity ^0.4.13;

contract LibSort {

  struct SortElement  {
    uint index; // index in fixed position array
    uint value; // value to be used to compare in the sort
  }

  SortElement[] data;

  function push(uint index, uint value) public {
    data.push(SortElement({index: index, value: value}));
  }

  function reset() public {
    data.length = 0;
  }

  function setValue(uint index, uint value) public {
    require(index < data.length);
    data[index].value = value;
  }

  function length() public returns (uint) {
    return data.length;
  }

  function get(uint index) public returns (uint, uint) {
    require(index < data.length);
    return (data[index].index, data[index].value);
  }

  // sort low to high (or high to low if inverse is true)
  function sort(bool inverse) public {

    if (0 == data.length) {
      return;
    }
    uint n = data.length;
    SortElement[] memory arr = new SortElement[](n);
    uint i;

    for(i=0; i<n; i++) {
      arr[i] = data[i];
    }

    uint[] memory stack = new uint[](n+2);

    //Push initial lower and higher bound
    uint top = 1;
    stack[top] = 0;
    top = top + 1;
    stack[top] = n-1;

    //Keep popping from stack while is not empty
    while (top > 0) {

      uint h = stack[top];
      top = top - 1;
      uint l = stack[top];
      top = top - 1;

      i = l;
      uint x = arr[h].value;

      for (uint j=l; j<h; j++){
        if  (arr[j].value <= x) {
          //Move smaller element
          (arr[i], arr[j]) = (arr[j],arr[i]);
          i = i + 1;
        }
      }
      (arr[i], arr[h]) = (arr[h],arr[i]);
      uint p = i;

      //Push left side to stack
      if (p > l + 1) {
        top = top + 1;
        stack[top] = l;
        top = top + 1;
        stack[top] = p - 1;
      }

      //Push right side to stack
      if (p+1 < h) {
        top = top + 1;
        stack[top] = p + 1;
        top = top + 1;
        stack[top] = h;
      }
    }
    if (inverse) {
      for(i=0; i<n; i++) {
        data[n-i-1] = arr[i];
      }
    }
    else {
      for(i=0; i<n; i++) {
        data[i] = arr[i];
      }
    }
  }
}

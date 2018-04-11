
pragma solidity ^0.4.9;

contract Match {

  struct Comp
  {
    uint hardware;
    uint software;
  }

  Comp[] matches;
  uint numberOfMatches;
  uint public nodeId;

  function Match() payable {
  }

  event query (address sender, uint node);
  event answerFound(uint software);

  function askForMatch(uint n){
    nodeId=n;
    clearArray();
    query(msg.sender, n);
  }

  function addMatch(uint h, uint s)
  {
    matches.push(Comp(h, s));
    if (matches.length==3){
      bubbleSort();
    }
  }

  function bubbleSort()
  {
    uint n = matches.length;
    while (n>0){
      uint v = 0;
      for (uint i=1; i<= (n-1); i++){
        if (matches[i-1].software>matches[i].software)
        {
          swap(i-1, i);
          v=i;
        }
      }
      n=v;
    }
    findBest();
  }

  function swap(uint index1, uint index2)
  {
    Comp memory temp = matches[index1];
    matches[index1] = matches[index2];
    matches[index2] = temp;
  }

  function findBest() returns(uint)
  {
    uint count = 1;
    uint tempCount;
    uint popular = matches[0].software;
    uint temp = 0;
    for (uint i = 0; i < (matches.length - 1); i++)
    {
      temp = matches[i].software;
      tempCount = 0;
      for (uint j = 1; j < matches.length; j++)
      {
        if (temp == matches[j].software)
          tempCount++;
      }
      if (tempCount > count)
      {
        popular = temp;
        count = tempCount;
      }
    }
    answerFound(popular);
    return popular;
  }


    function getMatch(uint n) constant returns (uint, uint){
      return (matches[n].hardware, matches[n].software);
    }

    function getLengthOfMatches() constant returns (uint){
      return matches.length;
    }

    function clearArray(){
      delete matches;
    }

    function getNumber() returns (uint){
      return 42;
    }
  }

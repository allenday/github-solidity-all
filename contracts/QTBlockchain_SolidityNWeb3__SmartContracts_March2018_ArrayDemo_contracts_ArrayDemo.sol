pragma solidity ^0.4.4;

contract ArrayDemo {
  function ArrayDemo() {
    // constructor
  }

  uint[] ranksDynamic;

  uint[10] ranksStatic;

  function getRankDynamic(uint256 index) returns (uint) {
    return ranksDynamic[index];
  }

  function setRankDynamic(uint rank) {
      // if the current allocation is empty
      // allocated size
      uint allSize=8;
      if(allSize==ranksDynamic.length){
        ranksDynamic.push(rank);
      }
      ranksDynamic[allSize] = rank;

           
  }


}

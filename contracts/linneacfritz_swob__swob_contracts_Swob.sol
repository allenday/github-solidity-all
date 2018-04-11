pragma solidity ^0.4.7;
//import "BigInt.sol";

contract Swob {

  struct Match {
    uint node;
    uint hardware;
    uint software;
    address sender;
  }

  uint public number_of_checks;
  //uint public numberOfChecks;
  address public caller;
  uint public nodeId;
  Match[] allMatches;
  //Match current;
  Match bestie;


  function Swob() payable{
  }

  function startCall(uint n){
    nodeId=n;
    number_of_checks=0;
    called(nodeId, msg.sender);
    setBestMatch(0,0,0);
  }

  //function startCall(uint n){
  //  nodeId=n;
    //number_of_checks=0;
  //  numberOfChecks=0;
  //  called(nodeId, msg.sender);
  //  setBestMatch(123,17,92,msg.sender);
  //}

event called (uint n, address caller);
event bestFound (uint n, uint h, uint s, address replier);

  modifier onlyCaller(){
    if (msg.sender != caller) throw;
    _;
  }

  modifier onlyNine(){
    if(number_of_checks>9) throw;
    _;
  }

  /*function findBestMatch(){
    if (allMatches[0].software == allMatches[1].software){
      setBestMatch(allMatches[0].hardware, allMatches[0].software, allMatches[0].timestamp, allMatches[0].sender);
    }
    else{
      if (allMatches[2].software == allMatches[1].software){
        setBestMatch(allMatches[1].hardware, allMatches[1].software, allMatches[1].timestamp, allMatches[1].sender);
      }
      if (allMatches[2].software == allMatches[0].software)
        setBestMatch(allMatches[0].hardware, allMatches[0].software, allMatches[0].timestamp, allMatches[0].sender);

      //else result = "No concisive answer. Please make call again.";
        else result = 0;
    }
  }*/

  function findBest(uint i, uint max){
    uint counter = 1;
    uint j = i+1;
    for (j; j<allMatches.length; j++){
      if (allMatches[j].software==allMatches[i].software){
        counter ++;
      }
    }

    if (counter>max){
      setBestMatch(allMatches[i].hardware, allMatches[i].software, allMatches[i].sender);
      findBest(i+1, counter);
    }
    else {findBest(i+1, max);
    }
  }

  function setBestMatch(uint h, uint s, address a){
    bestie = Match(nodeId, h, s, a);
  }

  function createMatch (uint h, uint s){
    caller=msg.sender;
    Match memory aMatch = Match(nodeId, h, s, msg.sender);
    allMatches.push(aMatch);
    number_of_checks++;

    if(number_of_checks==9){
      findBest(0,1);
      bestFound(bestie.node, bestie.hardware, bestie.software, bestie.sender);
    }
  }

/*  function bubbleSortAllMatches(){
    for(uint i = 0; i<8; i++){
      if (allMatches[i].software>allMatches[i+1].software){
        swap(i, i+1);
      }
    }
  }

  function swap (uint first, uint second){
    Match memory temp = Match(allMatches[first].node, allMatches[first].hardware, allMatches[first].software, allMatches[first].timestamp, allMatches[first].sender);
    allMatches[first] = Match(allMatches[second].node, allMatches[second].hardware, allMatches[second].software, allMatches[second].timestamp, allMatches[second].sender);
    allMatches[second]=temp;
  }*/


  function getNumberOfChecks() returns (uint){
    return Swob.number_of_checks;
  }

 //function getMatchFromList (uint i) returns (uint, uint, uint, uint, address){

function getMatchFromList (uint i) returns (uint, uint, uint, address){
   return (allMatches[i].node, allMatches[i].hardware, allMatches[i].software, allMatches[i].sender);
  }

  function getBestMatch() returns (uint, uint, uint, address){
    return (bestie.node, bestie.hardware, bestie.software, bestie.sender);
  }

  //function getResult() returns (uint){
  //  return result;
//  }

  //function endCall() onlyCaller {
//    winner=leader;
//  }

}

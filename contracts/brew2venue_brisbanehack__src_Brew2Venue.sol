pragma solidity ^0.4.10;
contract Bew2Venue
{
  
 enum beewType {lager,stout,porter,ipa}  
  
  struct bottle{
  string batch;
  uint256 date;
  int cost;
  int abvv;
}

function add (string _batch,int _cost ,int _abv) {
  bottle memory _bottle = bottle (_batch,block.timestamp,_cost,_abv); 
  bottles.push(_bottle);
}

bottle[] public bottles;


}
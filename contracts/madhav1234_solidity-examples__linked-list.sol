pragma solidity ^0.4.2;
contract Y{
   string head;
   struct Temp{
      address addr;
      string next;
      string current;
   }
mapping (string => Temp) _temp;
function Y(){
    _temp['root'].addr = 0;
    _temp['root'].next = 'root1';
    _temp['root'].current = 'root';
    
    head = 'root';
}
function addNodes(string _current, address _addr){
    string memory _curr = _current;
    _temp[_current].current = _curr;
    _temp[_current].next = head;
    _temp[_current].addr = _addr;
    
    head = _curr;
}

function addNodesToList(string _current, address _addr){
    string memory _curr = _current;
    _temp[_current].current = _curr;
    _temp[_current].next = head;
    _temp[_current].addr = _addr;
    
    head = _curr;
}


function getNodes(string _current) constant returns (string,string,address){
    string temp1 = _temp[_current].next;
    address _addr = _temp[_current].addr;
    string temp2 = _temp[_current].current;
    return (temp1,temp2,_addr);
}

}

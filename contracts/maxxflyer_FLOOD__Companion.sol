contract Companion{
address owner;
mapping(address => bool)public TOS; 
function Companion(){owner=msg.sender;}
function acceptTOS(address a,bool b){if(msg.sender==owner)TOS[a]=b;}
}

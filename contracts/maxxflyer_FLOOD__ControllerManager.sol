//controller manager - contiene gli hypercoin accettati senza coinvolgere la privacy
contract ControllerManager{
address[] controllers;
mapping(address => bool)public controllersCheck;
function ControllerManager(){}
function getController(uint contr)constant returns(address){address temp=0x0;if(controllersCheck[controllers[contr]])temp=controllers[contr];return temp;}
function addController(address a,bool b){if(b)controllers.push(a);controllersCheck[a]=b;}
}

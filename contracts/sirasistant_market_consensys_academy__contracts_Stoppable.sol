pragma solidity 0.4.15;

contract Stoppable{
    event LogStatusChanged(address indexed sender,bool newStatus);

    bool public running;
       
    function Stoppable(){
          running = true;
    }
    
    modifier isRunning(){require(running);_;}

    function setRunningInternal(bool newStatus)
    internal{
        bool oldStatus = running;
        if(oldStatus!=newStatus){
            running = newStatus;
            LogStatusChanged(msg.sender,newStatus);
        }
    }

    
}
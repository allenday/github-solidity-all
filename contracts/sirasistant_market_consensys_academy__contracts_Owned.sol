pragma solidity 0.4.15;

contract Owned{
    event LogOwnerChanged(address indexed oldOwner,address indexed newOwner);

    address public owner;
       
    function Owned(){
          owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

    function setOwner(address newOwner)
    public
    returns (bool success){
        require(msg.sender == owner);
        require(newOwner!=address(0));
        if(newOwner!=owner){
            owner = newOwner;
            LogOwnerChanged(msg.sender,newOwner);
            return true;
        }else{
            return false;
        }
    }

    function getOwner()
    public
    constant
    returns (address){
        return owner;
    }
    
    function kill()
    public
    returns(bool success){
        require(msg.sender==owner);
        suicide(owner);
        return true;
    }
}
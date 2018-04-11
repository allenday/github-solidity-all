pragma solidity ^0.4.6;

contract SimpleNameRegistry{
    
    //What's in a name?
    struct Name {
        string name;
        uint block_set;
    }
    
    mapping (address => Name) names;
    
    function setName(string _name){
        names[msg.sender].block_set = block.number;
        names[msg.sender].name = _name;
    }
    
    function getName(address account) constant returns(string){
        if(names[account].block_set > 0)
            return names[account].name;
        else
            return 'anonymous';
    }
}
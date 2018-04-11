pragma solidity ^0.4.2;

import './Forge.sol';

contract CoderForge{

    address public owner;

    address[] public forges;

    event LogForge(
        address _from,
        address forge,
        uint256 index
    );

    function CoderForge(){
        owner = msg.sender;
    }

    function getForge(uint256 index) public constant returns (address){
      address forge = forges[index];
      return forge;
    }

    function newForge(bytes32 name, bytes32 url, address orgWallet) public returns (uint256){

        Forge forge = new Forge();
        forge.setName(name);
        forge.setOrganiser(orgWallet);

        uint256 index = forges.push(forge);   // returns new array length;
        index--;

        LogForge(owner, forge, index);

        return index;
    }

    function kill() public constant returns (bool){
        if(msg.sender==owner){
            selfdestruct(msg.sender);
            return true;
        }
        return false;
    }
}

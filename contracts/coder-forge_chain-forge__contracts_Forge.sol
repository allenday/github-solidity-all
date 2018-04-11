pragma solidity ^0.4.2;

contract Forge{

    address owner;
    bytes32 public _name;
    address public _organiser;
    bytes32 public _url;
    mapping(address => uint) funds;

    function Forge(){
        owner = msg.sender;
    }

    // catch all
    function() payable{
        funds[_organiser] += msg.value;
    }

    function getBalance() constant returns(uint balance) {
  		  return this.balance;
  	}

    event TransferStatus(
        bytes32 message
    );

    // release funds to organizer
    function payOrganizer() payable returns(bool){
        uint fund = funds[_organiser];
        funds[_organiser] = 0;

        if(!_organiser.send(fund)){
            TransferStatus('it failed');
            funds[_organiser] = fund;
        }
        else{
            TransferStatus('success');
        }
        return true;
    }

    // set forge name
    function setName(bytes32 name) returns(bool){

        if(msg.sender==owner){
            _name = name;
            return true;
        }

        return false;
    }

    // set forge organiser
    function setOrganiser(address organiser) returns(bool){

        if(msg.sender==owner){
            _organiser = organiser;
            return true;
        }

        return false;
    }

    // set forge url (meetup, eventbrite, website etc)
    function setUrl(bytes32 url) returns(bool){

        if(msg.sender==owner){
            _url = url;
            return true;
        }

        return false;
    }

    function kill() returns(bool){
        if(msg.sender==owner){
            selfdestruct(msg.sender);
            return true;
        }

        return false;
    }
}

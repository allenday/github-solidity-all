pragma solidity ^0.4.10;
import "Ownable.sol";
contract Administrator is Ownable {
    
//    address public owner;
    address public idChain;
    uint    public it;
    
    event eParticipantAdded(address _address, string _name);
    
    // ROLE: 0 - don't exist, 1 - can do nothing, 2 - can do everything, 3 - only requests, 4 - only add
    struct Party {
        string  Name;
        uint8   Role;
        string  URL;
        string  URI;
        bytes32 agreementHash;
    }
    
    mapping (address => Party) public MParties;
    
    address[] public AParties;
    //mapping (address => string) public MName;
    
    function Parties (){
        owner = msg.sender;
    }
    
    function SetIDChain(address _address) onlyOwner {
        idChain = _address;
    }
    
    function AddParticipant(address _address, string _name, uint8 _role, string _url, string _uri, bytes32 _agreementHash) onlyOwner {
        bool exst = false;
        for (uint i = 0; i < AParties.length; i++){
            if (AParties[i] == _address){
                exst = true;
            }
        }
        if (!exst){
            Party memory _party;
            MParties[_address] = Party(_name, _role, _url, _uri, _agreementHash);
            AParties.push(_address);
            eParticipantAdded(_address, _name);
        }
    }
    
    function RemoveParticipant(address _address) onlyOwner returns(bool){
        uint index;
        bool exst = false;
        for (uint i = 0; i < AParties.length; i++){
            if (AParties[i] == _address){
                index = i;
                exst = true;
            }
        }
        if (!exst) {
            return false;
        }
        for (uint j = index; j< AParties.length-1; j++){
            AParties[j] = AParties[j+1];
        }
        delete AParties[AParties.length-1];
        AParties.length--;
        return true;
    }
    
    function GetParticipantRole(address _address) constant returns (uint8){
        if (msg.sender != idChain){
            return;
        }
        return MParties[_address].Role; 
    }
    
    function SetParticipantName(address _address, string _name) onlyOwner returns (bool){
        if (MParties[_address].Role == 0 ){
            return false;
        }
        MParties[_address].Name = _name;
        return true;
    }
    
    function SetParticipantRole(address _address, uint8 _role) onlyOwner returns (bool){
        if (MParties[_address].Role == 0 || ((_role != 1) && (_role != 2) && (_role !=3))){
            return false;
        }
        MParties[_address].Role = _role;
        return true;
    }
    
    function SetParticipantURL(address _address, string _url) onlyOwner returns (bool){
        if (MParties[_address].Role == 0 ){
            return false;
        }
        MParties[_address].URL = _url;
        return true;
    }
    
    function SetParticipantURI(address _address, string _uri) onlyOwner returns (bool){
        if (MParties[_address].Role == 0 ){
            return false;
        }
        MParties[_address].URI = _uri;
        return true;
    }
    
    function SetParticipantAgrHash(address _address, bytes32 _agreementHash) onlyOwner returns (bool){
        if (MParties[_address].Role == 0 ){
            return false;
        }
        MParties[_address].agreementHash = _agreementHash;
        return true;
    }
    
    function GetParticipant(address _address) onlyOwner constant returns (address, string, uint8, string, string, bytes32){
        return (_address, MParties[_address].Name
               , MParties[_address].Role
               , MParties[_address].URL
               , MParties[_address].URI
               , MParties[_address].agreementHash
               );
    }
    
    function List() constant returns (address[]){
        return AParties;
    }
    
    function changeOwner(address _newOwner) onlyOwner{
    if(_newOwner == 0x0) throw;
    owner = _newOwner;
    }
    
}
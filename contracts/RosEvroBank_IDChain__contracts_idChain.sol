pragma solidity ^0.4.10;
import "Ownable.sol";
import "Administrator.sol";
import "Identified.sol";

contract IDChain is Ownable {
    address  public partiesContract;
    address  public storageContract;

    //Data store
    Administrator public admin;
    Identified    public identified;
    
    mapping (bytes32  => mapping (bytes32 => address )) MHash1;
    mapping (address  => mapping (bytes32 => bool    )) MTokenPerm;
    
    event eHashAdded(bytes32 _hash);
    //event eAnswer(address _to, bytes32 _token, bool _result);
    //event eIdentified(bytes32 token, bytes32 hash);
    event eTokenGiven(address _to, bytes32 _token);
    event eAddCustomerHash(bytes32 _token, bytes32 _hash, address _address, uint8 _role);
    
    /* Initialization*/
    function IDChain() {
    }
     
    
    function SetAdminContract(address _address) onlyOwner {
        partiesContract = _address;
        admin = Administrator(partiesContract);
    }
    //function SetStorageContract(address _address) onlyOwner {
    //    storageContract = _address;
    //    //idstorage = idStorage(_address);
    //}
    function SetIdentifiedContract(address _address) onlyOwner {
        identified = Identified(_address);
    }
    function GetPartyRole(address _address) constant returns (uint8){
        //admin = Administrator(partiesContract);
        return admin.GetParticipantRole(_address);
    }
    
    function addCustomerHash(bytes32 _token, bytes32 _hash) returns (bool result){
        //bool result = false;
        uint8 crole = GetPartyRole(msg.sender);
        eAddCustomerHash(_token, _hash, msg.sender, crole);
        if ( crole == 0 || crole == 1 || crole == 3){
            return false;
        }
        if (_token.length == 0 || _hash.length ==0){
            return false;
        }
        MHash1[_token][_hash] = msg.sender;
        eHashAdded(_hash);
        //idstorage.setParticipantHash(_token, _hash, msg.sender, true);
        
        
        return true;
    }
    
    function GiveTokenPerm(address _address, bytes32 _token) returns (bool result){
        uint8 crole = GetPartyRole(msg.sender);
        if (_address == msg.sender){
            return false;
        }
        if (crole == 0 || crole == 1 || crole == 3){
            return false;
        }
        MTokenPerm[_address][_token] = true;
        //idstorage.setTokenPermission(_address, _token, true);
        eTokenGiven(_address, _token);
        return true;
    }
    
    function RequestP(bytes32 _token, bytes32 _hash) returns(bool hres1){
        //if (!idstorage.getTokenPermission(msg.sender, _token)){
        //    return;
        //}
        //if (   idstorage.getParticipantHashAddress(_token, _hash) != address(0x0) 
        //    && idstorage.getParticipantHashBool(_token, _hash)
        //   ){
        if (!MTokenPerm[msg.sender][_token]){
            return;
        }
        address _donor = MHash1[_token][_hash];
        if (   _donor != address(0x0) 
           ){
            hres1 = true;
            //eIdentified(_token, _hash);
            identified.identified(_donor, msg.sender, _hash);
            
        } else
        {   hres1 = false;
        }
    }
    
    function RequestTest(bytes32 _token, bytes32 _hash) onlyOwner constant
    returns(address){
        //return (idstorage.getParticipantHashAddress(_token, _hash), 
        //    idstorage.getParticipantHashBool(_token, _hash) 
        //   );
        return (MHash1[_token][_hash]
           );   
    }
    
    function RequestC(bytes32 _token, bytes32 _hash) constant
    returns(bool hres){
        //if (   idstorage.getParticipantHashAddress(_token, _hash) != address(0x0) 
        //    && idstorage.getParticipantHashBool(_token, _hash)
        //   ){
        if (   MHash1[_token][_hash] != address(0x0) 
           ){       
            hres = true;
        } else
        {   hres = false;
        }
    }
   
    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}
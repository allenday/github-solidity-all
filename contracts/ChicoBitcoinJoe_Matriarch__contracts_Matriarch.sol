pragma solidity^0.4.8;

import "MiniMeToken.sol";

contract Matriarch is Controlled {
    
    struct MeDAO {
        address owner;
        address meDao;
        string description_hash;
        bool vetted;
    }
    
    uint public total_daos;
    mapping (uint => address) public index;
    mapping (address => MeDAO) public meDaos;
    
    function registerMeDao(address _meDao) {
        if(meDaos[msg.sender].owner == msg.sender)
            throw;
            
        index[total_daos] = msg.sender;
        meDaos[msg.sender] = MeDAO(msg.sender,_meDao,'',false);
        total_daos++;
    }
    
    function updateMeDao(address _newMeDao) {
        meDaos[msg.sender].meDao = _newMeDao;
    }
    
    function updateDescriptionHash(string _description_hash) {
        meDaos[msg.sender].description_hash = _description_hash;
    }
    
    function isVetted(address _account) constant returns (bool) {
        return meDaos[_account].vetted;
    }
    
    function vet(address _ceo, bool _vetted) onlyController {
        meDaos[_ceo].vetted = _vetted;
    }
    
}
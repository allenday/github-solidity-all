pragma solidity ^0.4.7;

contract ChainSign { 
    mapping(bytes32 => mapping (address => uint)) private sign_book;
    mapping(bytes32 => address) private ownership_book;
    mapping(bytes32 => address) private registrant_book;

    function ChainSign(){
    	
    }
    
    function sign(bytes32 data_hash) public {
        require(!is_signed(msg.sender, data_hash));
        if(!is_registered(data_hash)){
            register(data_hash);
        }
        
        sign_book[data_hash][msg.sender] = block.number;
        if(registrant_book[data_hash] == 0) revert();
    }
    
    function register(bytes32 data_hash) private {
        require(!is_registered(data_hash));
        
        registrant_book[data_hash] = msg.sender;
        ownership_book[data_hash] = msg.sender;
        if(registrant_book[data_hash] != ownership_book[data_hash]) revert();
    }
    
    function transfer_ownership(bytes32 data_hash, address target) public {
        require(ownership_book[data_hash] == msg.sender);
        
        ownership_book[data_hash] = target;
    }

    function get_registrant(bytes32 data_hash) public constant returns (address) {
        return registrant_book[data_hash];
    }
        
    function is_registered(bytes32 data_hash) public constant returns (bool) {
        if(get_registrant(data_hash) == 0) {
            return false;
        }
        
        return true;
    }
    
    function get_owner(bytes32 data_hash) public constant returns (address) {
        return ownership_book[data_hash];
    }

    function get_signature_block(address by_address, bytes32 data_hash) public constant returns (uint) {
        return sign_book[data_hash][by_address];
    }
    
    function is_signed(address by_address, bytes32 data_hash) public constant returns (bool) {
        if(get_signature_block(by_address, data_hash) == 0){
            return false;
        }
        
        return true;
    }
}

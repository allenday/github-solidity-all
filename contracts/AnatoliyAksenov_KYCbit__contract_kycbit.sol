pragma solidity ^0.4.4;
contract KYCbit4 {
    /* Public variables of the token */
    address  public owner;
    uint8    public isins;
    bytes8  public bananax;
    address  public varex;
    
    mapping (address  => address) public HashToAddress;
    mapping (address  => string ) public HashToBIK;
    mapping (address  => string ) public HashToIntID;
    

    event Insert(address indexed from);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function KYCbit4() {
        owner = msg.sender;
        bananax = 'ananax';
    }

    function CustomerInsert(string _BIK, address _hash, string _intID) returns (address result){
        //HashToAddress[_hash] = msg.sender;
        HashToBIK[_hash] = _BIK;
        HashToIntID[_hash] = _intID;
        varex = _hash;
    return _hash;
    }
    
    function BIKQuery(address _hash) constant returns (string BIK){
        return HashToBIK[_hash];
    }

    function AddressQuery(address _hash) constant returns (address _address){
        return HashToAddress[_hash];
    }
    
    function IntIDQuery(address _hash) constant returns (string _intID){
        return HashToIntID[_hash];
    }
    
    function test() constant returns (string _BIK, string IntID){
         return (HashToBIK[0xa18fdc5ca4dab088722bcaf62a31255dca032f76], HashToIntID[0xa18fdc5ca4dab088722bcaf62a31255dca032f76]);
    }
    
    
    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}

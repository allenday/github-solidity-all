pragma solidity ^ 0.4.13;
contract Certificate {
    address public certificateIssuer;
    bytes32 public idHash;
    string public sundryData;
    bool public isDeleted;
    
    function Certificate(bytes32 hash, string sundry){
        certificateIssuer = msg.sender;
        idHash = hash;
        sundryData = sundry;
        isDeleted = false;
    }
    
    modifier isCertificateOwner() {
        if (msg.sender != certificateIssuer) revert();
        _;
    }
    
    function deleteCertificate() public isCertificateOwner{
        isDeleted = true;
    }
}
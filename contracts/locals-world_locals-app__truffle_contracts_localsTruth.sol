// Currently deployed at 0xD03B921AcF364cf8e240aEd920a539C53FF988CC

import "./localsCointoken.sol";
contract localsTruth {

    address public owner;
    
    // Which tokencontract to use
    localsCointoken public token;

    // the address of the tokencontract to use
    address public tokenaddr;

    // Threshold for verification status
    uint public verificationthresh;

    struct Hash {
        address hashowner;
        string thehash;
        mapping(address => bool) verifications;
        uint numVerifications;
    }

    mapping (string => Hash) hashes;

    event ValidationAdded(address _from, address _to, uint _numverifications);
    event Error(string _err);

    function localsTruth(address token, uint _verificationthresh){
        owner = msg.sender;
        tokenaddr = token;
        verificationthresh = _verificationthresh;
    }

    function addVerification(address _hashowner, string _thehash, string _senderhash) returns (string _feedback) {      
        // Add a verfier to this user's hash

        // If the verifier isnt verified himself, throw.
        if(hashes[_senderhash].numVerifications < verificationthresh) {
            Error('verifier has not enough verifications.');
            return 'verifier has not enough verifications.';
        }
        
        // If the verifier already verified this hash, throw.
        if(hashes[_thehash].verifications[msg.sender] == true) {
            Error('msg sender already verified this.');
            return 'msg sender already verified this.';
        }
        
        var tokencontract = localsCointoken(tokenaddr);

        uint numval = hashes[_thehash].numVerifications;
        hashes[_thehash].verifications[msg.sender] = true;
        hashes[_thehash].numVerifications = numval + 1;

        ValidationAdded(msg.sender, _hashowner, hashes[_thehash].numVerifications);
        // And transfer x localcoin from verifier to user.
        tokencontract.mintToken(msg.sender, 5);
        tokencontract.mintToken(_hashowner, 5);
        
    }

    function seedVerification(string _thehash){
        if(msg.sender != owner) throw;
        hashes[_thehash].numVerifications = 2;
    }

    function checkVeracity(string _hash) returns (uint numVerifications) {
    	return hashes[_hash].numVerifications;
    }

    // And because my mist wallet is getting full, we need a suicide function.
    function kill() { if (msg.sender == owner) suicide(owner); }

}


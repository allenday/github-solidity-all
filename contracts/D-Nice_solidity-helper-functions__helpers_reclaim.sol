//allows you to reclaim control of a contract, in case you lose access to the original sender address
//The contract uses Keccak-256 due to its lower cost, for greater 'theoretical' security use SHA-2, although it's more expensive
//When creating contract, within the constructor provide the salted hash to be used for reclaiming the contract
//When reclaiming ownership, you must provide the input and salt strings for the hash, along with a NEW and secure hash
//to replace the old hash, as it will be come visible to all on the blockchain

contract Reclaimer {
    
    //function reclaim
    address public owner;
    bytes32 private reclaim;
    
    function Reclaimer(bytes32 _reclaimHash) {
        reclaim = _reclaimHash;
        owner = msg.sender;
    }
    
    function reclaimOwnership(string _input, string _salt, bytes32 _newHash) {
        if (sha3(_input, _salt) == reclaim) {
            owner = msg.sender;
            reclaim = _newHash;
        }
    }
}

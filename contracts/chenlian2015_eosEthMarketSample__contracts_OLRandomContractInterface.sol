pragma solidity ^0.4.15;
import "./OLServerInterface.sol";

contract OLRandomContractInterface is OLServerInterface{

    /*
    one random number perhaps applied to multi requests
    @param callBackAddress  the address to receive random number
    */

    function requestOneUUID(address callBackAddress, uint versionCaller) public returns (uint code);

    /*
    randdom number needs seed and hash, every random number, needs 3 different hashes from different sender,
    when hash count is enough(3 count),then you can provide seed which relevant to the hash you just provide.
    every random number,one provider only can provide one seed and one hash(seed)
    */
    function sendOnlyHash(bytes32 hash) public returns (uint);

    /*
    hash(seed) must be equel to hash, or else,you perhaps be added to blacklist
    */
    function sendSeedAndHash(bytes32 seed, bytes32 hash) public returns (uint);

    /*
    @return uint ,the count of random number need to be generated
    */
    function getCurrentNeedsCount() public returns (uint);

    function nowCanProvideHash() public returns (bool);
}
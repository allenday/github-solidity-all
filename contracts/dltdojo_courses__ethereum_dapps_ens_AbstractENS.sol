pragma solidity ^0.4.15;
//
// https://github.com/ethereum/ens/blob/master/contracts/AbstractENS.sol
// 
contract AbstractENS {
    function owner(bytes32 node) constant returns(address);
    function resolver(bytes32 node) constant returns(address);
    function ttl(bytes32 node) constant returns(uint64);
    function setOwner(bytes32 node, address _owner);
    function setSubnodeOwner(bytes32 node, bytes32 label, address _owner);
    function setResolver(bytes32 node, address _resolver);
    function setTTL(bytes32 node, uint64 _ttl);

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address _owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address _owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address _resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 _ttl);
}
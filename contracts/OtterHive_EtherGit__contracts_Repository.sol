pragma solidity ^0.4.6;

contract Repository {
    uint public transactionCount = 0;
    mapping (bytes32 => Ref) public refs;
    mapping (bytes32 => GitObject) public objects;

    event CreateRef (bytes32 refname, string hash, address owner);
    event UpdateRef (bytes32 refname, string hash, address owner);
    event DeleteRef (bytes32 refname, address owner);

    struct Ref {
        address owner;
        string hash;
    }

    enum ObjectType { tag, commit, tree, blob }
    struct GitObject {
        ObjectType objectType;
        string bzzHash;
    }

    modifier onlyNew (bytes32 refname) {
        if (refs[refname].owner != 0x0) {
            throw;
        }
        _;
    }

    modifier neverMaster (bytes32 refname) {
        if (refname == 'master') {
            throw;
        }
        _;
    }

    modifier onlyOwner (bytes32 refname) {
        if (msg.sender != refs[refname].owner) {
            throw;
        }
        _;
    }

    modifier transaction () {
        transactionCount++;
        _;
    }

    function createRef (bytes32 refname, string hash) transaction() neverMaster(refname) onlyNew(refname) {
        CreateRef(refname, hash, msg.sender);
        refs[refname] = Ref(msg.sender, hash);
    }

    function updateRef (bytes32 refname, string hash) transaction() neverMaster(refname) onlyOwner(refname) {
        UpdateRef(refname, hash, refs[refname].owner);
        refs[refname].hash = hash;
    }

    function deleteRef (bytes32 refname) transaction() neverMaster(refname) onlyOwner(refname) {
        DeleteRef(refname, refs[refname].owner);
        delete refs[refname];
    }

    function createObject (bytes32 gitHash, string bzzHash, ObjectType objectType) {
        objects[gitHash] = GitObject(objectType, bzzHash);
    }
}

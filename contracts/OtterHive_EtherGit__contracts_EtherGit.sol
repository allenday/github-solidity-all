pragma solidity ^0.4.0;

contract EtherGit {
    address public creator;
    address public proxy;
    mapping (bytes32 => Repository) public repositories;

    modifier onlyFromProxy () {
        if (msg.sender != proxy) {
            throw;
        }
        _;
    }

    struct Repository {
        address owner;
        bytes data;
    }

    function EtherGit(address _proxy) {
        creator = msg.sender;
        proxy = _proxy;
    }

    function createRepository(bytes32 name, bytes data) onlyFromProxy() {
        repositories[name] = Repository(msg.sender, data);
    }
}

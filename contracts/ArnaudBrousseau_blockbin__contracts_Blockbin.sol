pragma solidity ^0.4.4;

contract Blockbin {

    // TODO: switch to governance-style deletion instead of
    // monarchy-style with an array of admins.
    address BlockbinAdmin;

    // TODO: do we need other fields?
    struct Cube {
        bool dumped;
        bool softDeleted;
        bytes32 hash;
        address owner;
        bytes data;
    }

    function Blockbin() {
        BlockbinAdmin = msg.sender;
    }

    // Main Storage structure for Cubes
    mapping (bytes32 => Cube) allCubes;


    modifier onlyAdmin() {
        if (msg.sender != BlockbinAdmin) {
            revert();
        }
        // Do not forget the "_;"! It will be replaced by the actual function
        // body when the modifier is used.
        _;
    }

    function softDelete(bytes32 hash) returns (bool success) {
        Cube memory cube = allCubes[hash];
        if (msg.sender != cube.owner) {
            revert();
        }

        allCubes[hash].softDeleted = true;
        return true;
    }

    function softUndelete(bytes32 hash) returns (bool success) {
        Cube memory cube = allCubes[hash];
        if (msg.sender != cube.owner) {
            revert();
        }

        allCubes[hash].softDeleted = false;
        return true;
    }

    function empty(bytes32 hash) returns (bool success) {
        Cube memory cube = allCubes[hash];
        if (msg.sender != cube.owner) {
            revert();
        }

        delete allCubes[hash];
        return true;
    }

    function forceEmpty (bytes32 hash) onlyAdmin returns (bool success) {
        delete allCubes[hash];
        return true;
    }

    function dumpCube(bytes data, bytes32 hash) returns (bool success) {
        if (allCubes[hash].dumped) {
            // A cube with this hash is already stored. Abort.
            return false;
        } else {
            // Proceed to storing new cube
            allCubes[hash] = Cube({
                dumped: true,
                softDeleted: false,
                hash: hash,
                owner: msg.sender,
                data: data
            });
            return true;
        }
    }

    function readCube(bytes32 hash) constant returns (bytes) {
        Cube memory cube = allCubes[hash];
        if (cube.dumped && !cube.softDeleted) {
            return cube.data;
        } else {
            bytes memory emptyBytes;
            return emptyBytes;
        }
    }
}

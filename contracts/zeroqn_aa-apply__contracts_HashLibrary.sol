pragma solidity ^0.4.17;


library HashLibrary {

    function hash(string property)
        internal pure returns (bytes32)
    {
        return keccak256("/Employee", property);
    }

    function hash(string property, uint id)
        internal pure returns (bytes32)
    {
        return keccak256("/Employee", id, property);
    }

    function hash(string property, address account)
        internal pure returns (bytes32)
    {
        return keccak256("/Employee", account, property);
    }

    function hash(
        string property,
        uint256 id,
        uint256 nonce,
        uint idx
    )
        internal pure returns (bytes32)
    {
        return keccak256(
            "/Employee",
            id,
            property,
            nonce,
            idx
        );
    }

    function hash(
        string property,
        uint256 id,
        uint256 nonce,
        address addr
    )
        internal pure returns (bytes32)
    {
        return keccak256(
            "/Employee",
            id,
            property,
            nonce,
            addr
        );
    }

}

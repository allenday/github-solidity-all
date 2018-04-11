contract Authority {

    enum Type {
        Null,
        SingleSigner,
        MultiSigner
    }

    enum Error {
        NoError,
        AccessDenied,
        InvalidHash,
        HashNotFound,
        HashAlreadySigned
    }

    event Sign(bytes32 indexed hash, uint indexed error);

    function sign(bytes32 hash) returns (Error error);
    function signed(bytes32 hash) constant returns (bool signed);
    function isSigner(address addr) constant returns (bool);
    function authType() constant returns (Type authType);
}

/// @title SingleSignerAuthority
/// @author Andreas Olofsson (androlo1980@gmail.com)
contract SingleSignerAuthority is Authority {

    mapping(bytes32 => uint) _hashes;

    address _signer = msg.sender;

    /// @notice Sign a (non zero) 32 byte hash. Can only be done by the contract 'signer'.
    /// @dev Sign a hash. The 'Error' enum can be found in the 'Authority' contract.
    /// @param hash The hash.
    /// @return The error code.
    function sign(bytes32 hash) returns (Error error) {
        if (_hashes[hash] != 0)
            error = Error.HashAlreadySigned;
        if (msg.sender != _signer)
            error = Error.AccessDenied;
        else if (hash == 0)
            error = Error.InvalidHash;
        else
            _hashes[hash] = now;
        Sign(hash, uint(error));
    }

    /// @dev Check if a hash is signed.
    /// @param hash The hash.
    /// @return 'true' if the hash is signed.
    function signed(bytes32 hash) constant returns (bool signed) {
        return _hashes[hash] != 0;
    }

    /// @dev Check the signing date of a hash. Returns 0 if the hash does not exist.
    /// @param hash The hash.
    /// @return The timestamp from the block in which the transaction was signed.
    function signDate(bytes32 hash) constant returns (uint signDate) {
        return _hashes[hash];
    }

    /// @dev Check if an address is the signer.
    /// @param addr The address.
    /// @return 'true' if the address is the signer.
    function isSigner(address addr) constant returns (bool) {
        return addr == _signer;
    }

    /// @dev Get the address of the signer
    /// @return The address of the signer.
    function signer() constant returns (address signer) {
        return _signer;
    }

    /// @dev Get the type of the authority contract. The 'Type' enum can be found in the 'Authority' contract.
    /// @return The type.
    function authType() constant returns (Type authType) {
        return Type.SingleSigner;
    }

}
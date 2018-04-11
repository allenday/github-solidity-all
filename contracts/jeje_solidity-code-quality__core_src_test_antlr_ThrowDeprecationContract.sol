pragma solidity ^0.4.0;


contract ThrowDeprecationContract {
    address owner;

    function useSuperPowers(){
        // do something only the owner should be allowed to do
        if (msg.sender != owner) {
            throw;
        }
    }
}

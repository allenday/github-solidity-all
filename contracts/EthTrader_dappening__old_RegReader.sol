pragma solidity ^0.4.17;

import "./Registry.sol";

contract RegReader {

    Registry registry;

    function RegReader(address _registry) {
        registry = Registry(_registry);
    }

    // not really working as we want the complete user details
    /*function getUserByUsername(bytes20 _username) public view returns (bytes20 username, address owner, uint32 joined, int24[4] postScores, int24[4] commentScores, uint32[4] modStarts) {*/
    function getUserByUsername(bytes20 _username) public view returns (bytes20 username, address owner, uint32 joined, uint16 rootIndex) {
        return registry.users(registry.usernameToIndex(_username));
        /*Registry.User storage user = registry.users(registry.usernameToIndex(_username));
        return (user.username, user.owner, user.joined, user.postScores, user.commentScores, user.modStarts);*/
    }

    function getIndexBatchByUsername(bytes20[] _usernames) public view returns (uint[50] registered) {
        require(_usernames.length <= 50);
        for (uint i = 0; i < _usernames.length; i++) {
            registered[i] = registry.usernameToIndex(_usernames[i]);
        }
    }

    // not working
    /*function getAddressBatchByUsername(bytes20[] _usernames) public view returns (address[50] addresses) {
        require(_usernames.length <= 50);
        for (uint i = 0; i < _usernames.length; i++) {
            addresses[i] = registry.users(registry.usernameToIndex(_usernames[i]))[1]; //.owner;
        }
    }*/

}

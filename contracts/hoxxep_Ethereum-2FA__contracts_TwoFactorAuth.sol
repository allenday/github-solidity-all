pragma solidity ^0.4.13;


/// Use an ethereum address as proof of 2FA instead of a phone number.
contract TwoFactorAuth {
    string public url;
    string public service;

    /// @dev The event which logs an Ethereum 2FA call that a server can listen to.
    event Authenticated(address _user);

    /// Set the url and service strings on construction.
    /// @param _url The url this contract is intended to provide 2FA for.
    /// @param _service The name of the service this contract intends to provide 2FA for.
    function TwoFactorAuth(string _url, string _service) {
        url = _url;
        service = _service;
    }

    /// Default function rejects payments but has enough gas to authenticate users.
    function () external {
        Authenticated(msg.sender);
    }

    /// Authenticate a user.
    function authenticate() {
        Authenticated(msg.sender);
    }
}

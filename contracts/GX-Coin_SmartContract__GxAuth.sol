pragma solidity ^0.4.2;

import './GxAuthority.sol';


contract GxAuth {
    enum AuthMode {
        Owner,
        Authority
    }

    AuthMode public authMode;
    GxAuthority public authority;

    function GxAuth() {
        authority = GxAuthority(msg.sender);
        authMode = AuthMode.Owner;
    }

    modifier auth {
        if (isAuthorized()) {
            _;
        } else {
            throw;
        }
    }

    function isAuthorized() internal returns (bool is_authorized) {
        if (authMode == AuthMode.Owner) {
            return msg.sender == address(authority);
        }

        if (authMode == AuthMode.Authority) {
            return authority.canCall(msg.sender, address(this), msg.sig);
        }

        throw;
    }

    function setAuthorityContract(address new_authority, AuthMode new_authMode) auth()
    {
        authority = GxAuthority(new_authority);
        authMode = new_authMode;
    }
}
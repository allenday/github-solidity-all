/*
 * Copyright 2016 Modum.io and the CSG Group at University of Zurich
 *
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */


/**
 * To make this work, the following server endpoints are necessary:
 *
 * sign(json) -> creates contract identity contract (signs data), adds to registry
 * update(json) -> updates contract identity contract (signs data)
 *
 */

contract Identity {
    address owner;
    address adminGroup;
    uint256 signatureHash;
    //AES256 encrypted data is JSON and may contain:
    // * personal_info / email, password (salted+hashed)
    mapping (string => bytes) encryptions; //token hints, first one is from our server can be added or removed

    /* */
    function Identity(address _owner, address _adminGroup) {
        owner = _owner;
        adminGroup = _adminGroup;
    }

    /* Called by the admin or owner if data changed */
    function update(uint256 _signatureHash) {
        if (isAdmin(msg.sender)) {
            signatureHash = _signatureHash;
        }
    }

    function isAdmin(address _addr) constant returns (bool) {
        if(adminGroup != 0) {
            return AdminGroup(adminGroup).isAdmin(_addr);
        } else {
            return owner == _addr;
        }
        return false;
    }

    /*
     * The owner can decide to add or remove tokens. The token is used to
     * decrypt the data. The data and the token can be removed at any given
     * time.
     */
    function addToken(string _hint, bytes _encryptedData) {
        if (msg.sender == owner || isAdmin(msg.sender)) {
            encryptions[_hint] = _encryptedData;
        }
    }

    function removeToken(string _hint) {
        if (msg.sender == owner || isAdmin(msg.sender)) {
            delete encryptions[_hint];
        }
    }

    function get(string _hint) constant returns (bytes) {
        return encryptions[_hint];
    }

    function getSignatureHash() constant returns (uint256) {
        return signatureHash;
    }

    function checkIdentifier(string _identifier) constant returns (bool) {
        //return sha3(_identifier) == sha3(adminGroup.getIdentifier());
    }

    /* Any remaining funds should be sent back to the server */
    function done() {
        if (isAdmin(msg.sender)) {
            suicide(msg.sender);
        }
    }
}

/* handled by modum.io, multiple admin groups per company possible */
contract AdminGroup {
    address server; //moduim.io key
    address[] admin;
    string identifier;
    function AdminGroup(string _identifier) {
        server = msg.sender;
        identifier = _identifier;
    }

    function add(address _addr) {
        //server cannot add to an admin group
        if(isAdmin(msg.sender)) {
            admin.push(msg.sender);
        }
    }

    function isAdmin(address _addr) constant returns (bool) {
        for(uint i = 0; i < admin.length; i++) {
            if(admin[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    function getIdentifier() constant returns (string) {
        return identifier;
    }

    function done() {
        if (server == msg.sender) {
            suicide(msg.sender);
        }
    }
}

/* per app one registry, handled by modum.io. */
contract IdentityRegistry {
    address server; //moduim.io key
    struct Entry {
        bool exists;
        address contractAddress;
        address owner;
    }
    mapping (uint256 => Entry) registry;

    function IdentityRegistry() {
        server = msg.sender;
    }

    function addEmailHash(uint256 _emailHash, address _contract) {
        if (registry[_emailHash].exists) {
            if(registry[_emailHash].owner == msg.sender || server == msg.sender) {
                registry[_emailHash] = Entry(true, _contract, registry[_emailHash].owner);
            } else {
                throw;
            }
        } else {
            registry[_emailHash] = Entry(true, _contract, msg.sender);
        }
    }

    function removeEmailHash(uint256 _emailHash) {
        if (registry[_emailHash].exists) {
            if(registry[_emailHash].owner == msg.sender || server == msg.sender) {
                delete registry[_emailHash];
            } else {
                throw;
            }
        }
    }

    /*
     * Everbody can lookup an entry
     */
    function get(uint256 _emailHash) constant returns (address) {
        return registry[_emailHash].contractAddress;
    }

    function done() {
        if (msg.sender == server) {
            suicide(server);
        }
    }
}

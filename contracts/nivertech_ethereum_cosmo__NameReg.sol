// https://docs.google.com/presentation/d/1vBViqLBR0bD3hOY_SgQUwMFj9Nq8eCgggCmlx6_Tz04/edit#slide=id.g9c64d1696_0_46

// https://gist.github.com/kobigurk/da15a2f1eaef47f173a3 

import "owned";

contract NameReg is owned {
    event AddressRegistered(address indexed account);
    event AddressDeregistered(address indexed account);

    function NameReg() {
        toName[this] = "NameReg";
        toAddress["NameReg"] = this;
        AddressRegistered(this);
    }

    function register(bytes32 name) {
        // Don't allow the same name to be overwritten.
        if (toAddress[name] != address(0))
            return;
        // Unregister previous name if there was one.
        if (toName[msg.sender] != "")
            toAddress[toName[msg.sender]] = 0;
        
        toName[msg.sender] = name;
        toAddress[name] = msg.sender;
        AddressRegistered(msg.sender);
    }

    function unregister() {
        bytes32 n = toName[msg.sender];
        if (n == "")
            return;
        AddressDeregistered(toAddress[n]);
        toName[msg.sender] = "";
        toAddress[n] = address(0);
    }

    function addressOf(bytes32 name) constant returns (address addr) {
        return toAddress[name];
    }

    function nameOf(address addr) constant returns (bytes32 name) {
        return toName[addr];
    }
    
    mapping (address => bytes32) toName;
    mapping (bytes32 => address) toAddress;
}

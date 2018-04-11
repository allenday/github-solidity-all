contract AuthorizedAddresses {
    modifier noEther() {if (msg.value > 0) throw; _}

    // mapping of dthAddress -> petition.
    mapping (address => address) representedDTH;

    function getRepresentedDTH(address _authorizedAddress) noEther constant returns(address _dth) {
        return representedDTH[_authorizedAddress];
    }

    address public owner;
    bool public sealed;

    function AuthorizedAddresses() {
        owner = msg.sender;
    }

    function fill(uint[] data) noEther {
        if ((msg.sender != owner)||(sealed))
            throw;

        for (uint i=0; i< data.length; i+= 2) {
            address dth = address(data[i]);
            address authorizedAddress = address(data[i+1]);
            representedDTH[authorizedAddress] = dth;
        }
    }

    function seal() noEther {
        if ((msg.sender != owner)||(sealed))
            throw;

        sealed= true;
    }
}

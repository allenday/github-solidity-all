pragma solidity ^0.4.4;

import "./Cmc.sol";
import "./DnsDB.sol";
import "./CmcEnabled.sol";

contract SolDnsApp is CmcEnabled {

    bytes32 dnsDbName = "dnsdb";

    function register(bytes32 dnsName, bytes32 entry) returns (bool _success)  { 
    
        address dnsDbAddress = getContract(dnsDbName);
        if(dnsDbAddress == 0x0)
            return false;

        DnsDB dnsDB = DnsDB(dnsDbAddress);

        address owner = dnsDB.getOwnerByName(dnsName);
        if(owner != 0x0 && owner != msg.sender)
            return false;

        return dnsDB.register(dnsName, entry, msg.sender);
    }

    function deleteEntryByName(bytes32 dnsName)  returns (bool _success) { 
        
        address dnsDbAddress = getContract(dnsDbName);
        if(dnsDbAddress == 0x0)
            return false;
        
        DnsDB dnsDB = DnsDB(dnsDbAddress);
        address owner = dnsDB.getOwnerByName(dnsName);
        if(owner != msg.sender)
            return false;

        return dnsDB.deleteEntryByName(dnsName);
    }

    function getEntryByName(bytes32 name) constant returns (bytes32 _entry) {
        address dnsDbAddress = getContract(dnsDbName);
        if(dnsDbAddress == 0x0)
            return 0xff;

        return DnsDB(dnsDbAddress).getEntryByName(name);
    }

    function getOwnerByName(bytes32 dnsName) constant returns (address _address){
        address dnsDbAddress = getContract(dnsDbName);
        if(dnsDbAddress == 0x0)
            return 0x0;
        
        return DnsDB(dnsDbAddress).getOwnerByName(dnsName);
     }
}
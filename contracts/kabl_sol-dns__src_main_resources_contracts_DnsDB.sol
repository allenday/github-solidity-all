pragma solidity ^0.4.4;

import "./CmcEnabled.sol";

contract DnsDB is CmcEnabled {
    
     struct DnsEntry
     {
         address owner;
         bytes32 entry;
     }

     mapping (bytes32 => DnsEntry) dnsEntriesByName;
     event eventDnsDB_newEntry(bytes32 dnsName, bytes32 entry);

     function register(bytes32 dnsName, bytes32 entry, address owner) callAllowed returns (bool _success)  {

        dnsEntriesByName[dnsName] = DnsEntry(owner, entry);
        eventDnsDB_newEntry(dnsName, entry);

        return true;
     }

     function deleteEntryByName(bytes32 dnsName) callAllowed returns (bool _success) {
        delete dnsEntriesByName[dnsName].owner;
        delete dnsEntriesByName[dnsName].entry;
        delete dnsEntriesByName[dnsName];
        return true;
     }

     function getEntryByName(bytes32 dnsName) callAllowed constant returns (bytes32 _entry) {
         if(dnsEntriesByName[dnsName].owner != address(0x0))
             return dnsEntriesByName[dnsName].entry;
         else
             return "404";
     }

     function getOwnerByName(bytes32 dnsName) callAllowed constant returns (address _address){
         return dnsEntriesByName[dnsName].owner;
     }
}

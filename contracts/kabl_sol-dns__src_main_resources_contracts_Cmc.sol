pragma solidity ^0.4.4;

import "./CmcEnabled.sol";
import "./SolDnsApp.sol";  //required because bootstrap

contract CmcReader {
  function getContract(bytes32 name) constant returns (address _address) {}
}

contract Cmc is CmcReader{

    address owner;

    // This is where we keep all the contracts.
    mapping (bytes32 => address) public contracts;

    modifier onlyOwner { //a modifier to reduce code replication
        if (msg.sender == owner) // this ensures that only the owner can access the function
            _;
    }
    // Constructor
    function Cmc(){
        owner = msg.sender;
    }

    function bootstrap() onlyOwner returns (bool _result){
        SolDnsApp solDnsApp = new SolDnsApp();
        DnsDB dnsdb = new DnsDB();

        if(!addContract("soldnsapp", solDnsApp, 0x0))
            return false;
        
        if(!addContract("dnsdb", dnsdb, "soldnsapp"))
            return false;

        return true;
    }

    // Add a new contract to CMC. This will overwrite an existing contract.
    function addContract(bytes32 name, address addr, bytes32 seniorName) onlyOwner returns (bool _result) {
        CmcEnabled cmcEnabled = CmcEnabled(addr);
        // Don't add the contract if this does not work.
        if(!cmcEnabled.init(address(this), seniorName)) {
            return false;
        }
        contracts[name] = addr;
        return true;
    }

    function getContract(bytes32 name) constant returns (address _address){
        return contracts[name];
    }

    // Remove a contract from CMC. We could also selfdestruct if we want to.
    function removeContract(bytes32 name) onlyOwner returns (bool _result) {
        if (contracts[name] == 0x0){
            return false;
        }
        contracts[name] = 0x0;
        return true;
    }

    function remove() onlyOwner {
        address dnsDb = contracts["dnsdb"];
        address solDnsApp = contracts["soldnsapp"];

        // Remove everything.
        if(dnsDb != 0x0){ CmcEnabled(dnsDb).remove(); }
        if(solDnsApp != 0x0){ CmcEnabled(solDnsApp).remove(); }

        selfdestruct(owner);
    }

}
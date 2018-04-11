pragma solidity ^0.4.0;
contract webServer {
  struct pageData{
    address owner;
    bytes32 timestamp;
    bytes[] data;
  }

  mapping(bytes32 => mapping(bytes32 => pageData)) public pages;
  event RegisterEvent(address owner, uint data);

  function set(bytes32 time, bytes32 domain, bytes32 name, bytes data) returns (bool result){
    if (pages[domain][name].owner != 0) {
        if (pages[domain][name].owner != msg.sender) {
            return false;
        }
    }
    if(pages[domain][name].timestamp!=time){
        deletePage(domain,name);
    }
    pages[domain][name].timestamp = time;
    pages[domain][name].owner = msg.sender;
    pages[domain][name].data.push(data);
    RegisterEvent(msg.sender, pages[domain][name].data.length);

    return true;
  }

  function get(bytes32 domain, bytes32 name, uint index) constant returns (bytes data){
    return pages[domain][name].data[index];
  }

  function deletePage(bytes32 domain, bytes32 name) returns (bool result){
    pages[domain][name].data.length=0;
    return true;
  }

  function getlen(bytes32 domain, bytes32 name) constant returns (uint leng){
    return pages[domain][name].data.length;
  }
}

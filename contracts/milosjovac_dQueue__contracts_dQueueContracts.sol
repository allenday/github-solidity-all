pragma solidity ^0.4.11;

// We have to specify what version of compiler this code will compile with

contract QueueManager {
    
    
    struct QueueInfo {
        bytes32 mDesc;
        bytes32 mTitle;
        address mOwnerAddress;
        address mQueueAddress;
        bytes32 mResourceType;
        bool mResourceLimited;
    }
    
    QueueInfo[] public queues;

    struct ResourceInfo {
        bytes32 mType;
        bytes32 mDesc;
        bytes32 mTitle;
        address mOwnerAddress;
        address mResourceAddress;
    }
    
    mapping(bytes32=>address) public resources;
    
    //todo: Protect this function call only to contract creator or 
    //who pays for the service 
    function createQueue (bytes32 title, bytes32 desc, bool freeToEnter, bytes32 data, bytes32 resourceType, bool limitedResource) returns (address)  {
        address newQueueAddress = new Queue(title, desc, freeToEnter, data, msg.sender);
        queues.push(QueueInfo({
            mDesc: desc,
            mTitle: title,
            mOwnerAddress: msg.sender,
            mQueueAddress: newQueueAddress,
            mResourceType: resourceType,
            mResourceLimited: limitedResource
        }));
        return newQueueAddress;
    }
    
    function createResource(bytes32 t, bytes32 desc, bytes32 title)
    {
        address newResourceAddress = new Resource(t, title, desc, msg.sender);
        resources[t] = newResourceAddress;
    }
    
    function getQueuesLength() constant returns (uint) {
        return queues.length;
    }
    
    function QueueManager()
    {
        createQueue("transpaltacija srca", "d", false, "data", "srce", true);
        createResource("srce", "srca za transplataciju", "srca");
    }
}
contract Queue {
    
    
    event ClientAdded(
        address cliendAddress,
        bytes32 data
    );
    event ClientRemoved(
        address clientAddress
    );
    
    struct Client {
        address id;
        uint timestamp;
        bytes32 data;
    }
    
    bytes32 title;
    bytes32 description;
    address creator;
    bool freeEntrance;
    uint startIndex;
    uint count;
    uint timestamp;
    bytes32 data;
    
    mapping(uint => Client) clients;
    
    // Add client to queue
    function pushClient(address clientAddress, bytes32 userData){
        if(freeEntrance || msg.sender == creator){
            clients[startIndex + count] = Client({
                id: clientAddress, 
                timestamp: now, 
                data: userData
            });
    
            count++;
            
            ClientAdded(clientAddress, userData);
        }
    }
    function popClient() returns (address, uint, bytes32){
        if(msg.sender == creator){
            if(count > 0){
                address removedAddress = clients[startIndex].id;
                uint removedTimestamp = clients[startIndex].timestamp;
                bytes32 removedData = clients[startIndex].data;
                delete clients[startIndex]; //brisanje sa pocetka
                startIndex++;
                count--;
                
                if(count == 0){
                    startIndex = 0;
                }
                
                ClientRemoved(removedAddress);
                return (removedAddress, removedTimestamp, removedData);
            }
        }
    }
    function getNumberOfClients() constant returns (uint){
        return count;
    }
    
    function getClientAtIndex(uint index) constant returns (address, uint, bytes32) {
        require(index >= 0 && index < count);
        
        uint offset = startIndex + index; 
        return (clients[offset].id, clients[offset].timestamp, clients[offset].data);
    }
    

    function Queue (bytes32 tit, bytes32 desc, bool isFreeToEnter, bytes32 dat, address cr) {
        title = tit;
        description = desc;
        creator = cr;
        freeEntrance = isFreeToEnter;
        startIndex = 0;
        data = dat;
        timestamp = now;
        count = 0;
    }
}

contract Resource
{
    
    event ResourceAvailable(
        bytes32 resourceType,
        uint32 count
    );
    
    bytes32 resourceType;
    bytes32 title;
    bytes32 description;
    address creator;
    uint32 count;
    
    function Resource(bytes32 typ, bytes32 tit, bytes32 desc, address cr)
    {
        resourceType = typ;
        title = tit;
        description = desc;
        creator = cr;
        count = 0;
    }
    
    function Add (uint32 quantity)
    {
        require(msg.sender == creator);
        
        count += quantity;
        ResourceAvailable(resourceType, count);
    }
    
    function Get() returns(bool)
    {
        require(msg.sender == creator);
        
        if(count > 0)
        {
            --count;
            return true;
        }
        else
        {
            return false;
        }
    }
}
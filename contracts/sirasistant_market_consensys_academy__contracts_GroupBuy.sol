pragma solidity 0.4.15;

import "./MarketHub.sol";
import "./Shop.sol";

contract GroupBuy is Owned,Wallet {
    
    event LogBuyRequestAdded(uint indexed requestId,address indexed creator ,bytes32 indexed productId,address shop);
    event LogJoinedBuyRequest(uint indexed requestId,address indexed collaborator,uint amount);
    event LogBuyRequestExecuted(uint indexed requestId,bytes32 indexed productId,address indexed shop);
    event LogExitedBuyRequest(uint indexed requestId,address indexed collaborator,uint amount);
    
    struct BuyRequest{
        address creator;
        uint totalAmount;
        bytes32 productId;
        bool paid;
        uint price;
        address shop;
        mapping(address=>uint) collaborators;
        uint index;
    }
    
    uint nextBuyRequestId = 0;
    
    mapping(uint=>BuyRequest) public buyRequests;
    
    uint[] public buyRequestIds;
    
    address public hub;
    
    function GroupBuy(address hubAddress){
        hub = hubAddress;
    }
    
    modifier existsBuyRequest(uint id){
        require(buyRequestIds[buyRequests[id].index]==id);
        _;
    }
    
    modifier productExists(bytes32 id,address _shop){
        Shop shop = Shop(_shop);
        shop.getProduct(id);
        _;
    }
    
    modifier productHasStock(bytes32 id,address _shop){
        Shop shop = Shop(_shop);
        var ( amount, price, name) = shop.getProduct(id);
        require(amount>0);
        _;
    }
    
    function addBuyRequestInternal(BuyRequest memory request)
    internal
    returns(uint id){
        id = nextBuyRequestId++;
        uint index = buyRequestIds.push(id)-1;
        request.index = index;
        buyRequests[id] = request;
    }
    
    function deleteBuyRequestInternal(uint id)
    internal
    existsBuyRequest(id){
        uint index = buyRequests[id].index;
        delete buyRequestIds[index];
        if(index!=buyRequestIds.length-1){
            uint idToSwap = buyRequestIds[buyRequestIds.length-1];
            buyRequests[idToSwap].index = index;
            buyRequestIds[index] = idToSwap;
        }
        buyRequestIds.length--;
    }
    
    function executeBuyRequest(uint requestId)
    internal
    productHasStock(buyRequests[requestId].productId,buyRequests[requestId].shop){
        buyRequests[requestId].paid = true;
        Shop shop = Shop(buyRequests[requestId].shop);
        shop.buy.value(buyRequests[requestId].totalAmount)(buyRequests[requestId].productId);
    }
    
    function addBuyRequest(bytes32 productId,address shopAddress)
    public
    returns(bool success){
        MarketHub hubInstance = MarketHub(hub);
        require(hubInstance.isTrustedShop(shopAddress));
        Shop shop = Shop(shopAddress);
        var ( amount, price, ) = shop.getProduct(productId);
        require(amount>0);
        BuyRequest memory newBuyRequest;
        newBuyRequest.creator = msg.sender;
        newBuyRequest.productId = productId;
        newBuyRequest.price = price;
        newBuyRequest.shop = shopAddress;
        uint id = addBuyRequestInternal(newBuyRequest);
        LogBuyRequestAdded(id,msg.sender,productId,shopAddress);
        
        return true;
    }
    
    function joinBuyRequest(uint requestId)
    public
    payable
    existsBuyRequest(requestId)
    returns(bool success){
        require(!buyRequests[requestId].paid);
        uint amountToAdd = msg.value;
        if(buyRequests[requestId].totalAmount+amountToAdd>buyRequests[requestId].price){
            uint diff = buyRequests[requestId].totalAmount+amountToAdd-buyRequests[requestId].price;
            amountToAdd-=diff;
            addMoneyInternal(msg.sender,diff);
        }
        buyRequests[requestId].totalAmount += amountToAdd;
        buyRequests[requestId].collaborators[msg.sender] += amountToAdd;
        if(buyRequests[requestId].totalAmount==buyRequests[requestId].price){
            executeBuyRequest(requestId);
        }
        LogJoinedBuyRequest( requestId,msg.sender,msg.value);
        if(buyRequests[requestId].totalAmount==buyRequests[requestId].price){
            LogBuyRequestExecuted(requestId,buyRequests[requestId].productId,buyRequests[requestId].shop);
        }
        return true;
    }
    
    function exitBuyRequest(uint requestId)
    public
    existsBuyRequest(requestId)
    returns(bool success){
        require(!buyRequests[requestId].paid);
        uint amountContributed = buyRequests[requestId].collaborators[msg.sender];
        buyRequests[requestId].totalAmount -=  amountContributed;
        buyRequests[requestId].collaborators[msg.sender] =0;
        addMoneyInternal(msg.sender,amountContributed);
        LogExitedBuyRequest(requestId,msg.sender,amountContributed);
        return true;
    }
    
    function getBuyRequestCount()
    public
    constant
    returns (uint amount){
        return buyRequestIds.length;
    }
    
    function getCollaborated(uint requestId)
    public
    constant
    existsBuyRequest(requestId)
    returns (uint amount){
        return buyRequests[requestId].collaborators[msg.sender];
    }
    
}







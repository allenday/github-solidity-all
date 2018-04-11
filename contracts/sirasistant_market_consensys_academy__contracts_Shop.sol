pragma solidity 0.4.15;

import "./Owned.sol";
import "./MarketHub.sol";
import "./Stoppable.sol";
import "./ERC20.sol";
import "./oraclizeAPI.sol";


contract Shop is Owned,Stoppable,usingOraclize {
    
    event LogAddProduct(bytes32 indexed id);
    event LogStockChanged(bytes32 indexed id);
    event LogBuy(bytes32 indexed id);
    event LogDeleteProduct(bytes32 indexed id);
    event NewOraclizeQuery(bytes32 indexed id);
    event Callback(bytes32 indexed id);

    
    struct Product{
        uint amount;
        uint price;
        bytes32 name;
        address token;
        uint index;
        bool exists;
    }
    
    bytes32[] public productIds;
    
    uint fee;
    
    address seller;
    
    mapping(bytes32=>Product) public products;
    mapping(bytes32=>Product) public pendingProducts;

    modifier onlySeller(address account){
        require(seller == account);
        _;
    }

    modifier onlyAllowedToken(address account){
        require(isAllowedToken(account)||account==address(0));
        _;
    }
    
    modifier productExists(bytes32 id){
        require(productIds[products[id].index]==id);
        _;
    }
    
    
    function Shop(uint _fee,address _seller) {
        seller = _seller;
        fee = _fee;
    }
    
    function isAllowedToken(address tokenAddress)
    returns (bool isIndeed){
        MarketHub hub = MarketHub(owner);
        return hub.isAllowedToken(tokenAddress);
    }
    
    function addProductInternal(Product newProduct)
    internal
    returns (bytes32 id){
        id = sha3(newProduct.name,newProduct.token,newProduct.price);
        require(!products[id].exists); //Check for hash collisions
        productIds.push(id);
        newProduct.index = productIds.length-1;
        newProduct.exists = true;
        products[id] = newProduct;
    }
    
    function deleteProductInternal(bytes32 id)
    internal
    productExists(id){
        uint index = products[id].index;
        delete products[id];
        delete productIds[index];
        if(index!=productIds.length-1){
            bytes32 idToSwap = productIds[productIds.length-1];
            products[idToSwap].index = index;
            productIds[index] = idToSwap;
        }
        productIds.length--;
    }
    
    function __callback(bytes32 requestId, string result) {
        Callback(requestId);
        //require(msg.sender == oraclize_cbAddress());
        uint ethPrice = stringToUint(result);
        Product storage toAdd = pendingProducts[requestId];
        toAdd.price = (toAdd.price*1000000000000000000)/ethPrice;
        if(toAdd.price>fee){
            bytes32 id = addProductInternal(toAdd);
            LogAddProduct(id);
        }
        delete pendingProducts[requestId];
    }
    
    function __callback(bytes32 requestId, string result,bytes proof) {
        Callback(requestId);
        //require(msg.sender == oraclize_cbAddress());
        uint ethPrice = stringToUint(result);
        Product storage toAdd = pendingProducts[requestId];
        toAdd.price = (toAdd.price*1000000000000000000)/ethPrice;
        if(toAdd.price>fee){
            bytes32 id = addProductInternal(toAdd);
            LogAddProduct(id);
        }
        delete pendingProducts[requestId];
    }

    function addProductInUsd(uint cents,uint amount,bytes32 name) 
    public
    payable
    returns (bool success){
        require(oraclize_getPrice("URL") < msg.value);
        Product memory newProduct;
        newProduct.price = cents;
        newProduct.amount = amount;
        newProduct.name = name;
        newProduct.token = address(0);
        
        bytes32 id = oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
        pendingProducts[id] = newProduct;
        NewOraclizeQuery(id);
        return true;
    }
    
    
    function addProduct(uint price,uint amount,bytes32 name,address tokenAddress)
    public 
    isRunning
    onlySeller(msg.sender)
    onlyAllowedToken(tokenAddress)
    returns(bool success){
        require(price>fee);
        require(amount>0);

        Product memory newProduct;
        newProduct.price = price;
        newProduct.amount = amount;
        newProduct.name = name;
        newProduct.token = tokenAddress;
        
        bytes32 id = addProductInternal(newProduct);
        
        LogAddProduct(id);
        
        return true;
    }
    
    function deleteProduct(bytes32 id)
    public 
    onlySeller(msg.sender)
    productExists(id)
    returns(bool success){
        require(msg.sender==seller);
        deleteProductInternal(id);
        
        LogDeleteProduct(id);
        return true;
    }
    
    function setProductStock(bytes32 id,uint amount)
    public 
    onlySeller(msg.sender)
    productExists(id)
    returns (bool success){
        Product storage savedProduct = products[id];

        savedProduct.amount = amount;
        
        LogStockChanged(id);
        
        return true;
    }
    
    function buyWithTokens(bytes32 id)
    public
    isRunning
    productExists(id)
    returns (bool success){
        Product storage savedProduct = products[id];
        require(savedProduct.amount>0);
        require(currentTokenTransfer.sender!=address(0));
        require(savedProduct.token != address(0));
        require(currentTokenTransfer.value==savedProduct.price);
        
        savedProduct.amount--;
        
        ERC20 token = ERC20(msg.sender);
        token.approveAndCall(owner,currentTokenTransfer.value,"");
        
        LogBuy(id);
        return true;
    }
    
    function buy(bytes32 id)
    public
    payable
    isRunning
    productExists(id)
    returns (bool success){
        require(savedProduct.amount>0);
        Product storage savedProduct = products[id];
        require(savedProduct.token == address(0));
        require(msg.value==savedProduct.price);
        
        savedProduct.amount--;
        
        MarketHub hub = MarketHub(owner);
        
        hub.registerBuy.value(msg.value)();
        
        LogBuy(id);
        return true;
    }
    
    function setRunning(bool running)
    public
    onlyOwner
    returns (bool success){
        setRunningInternal(running);
        return true;
    }
    
    function getProductsCount()
    public
    constant
    returns (uint amount){
        return productIds.length;
    }
    
    function getProduct(bytes32 id)
    public
    constant
    productExists(id)
    returns(uint amount,uint price,bytes32 name){
        Product memory product = products[id];
        return (product.amount,product.price,product.name);
    }
    
    struct TokenTransfer{
        address sender;
        uint value;
    }
    
    TokenTransfer currentTokenTransfer;
    
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData)
    public
    isRunning
    onlyAllowedToken(msg.sender){
        require(_token == msg.sender);
        ERC20 token = ERC20(_token);
        token.transferFrom( _from, this, _value);
        require(_extraData.length!=0);
        currentTokenTransfer = TokenTransfer({
            sender:_from,
            value:_value
        });
        require(this.delegatecall(_extraData));
        delete currentTokenTransfer;
        
    }

    function tokenFallback(address _from, uint _value, bytes _data)
    public
    isRunning
    onlyAllowedToken(msg.sender){
        require(_data.length!=0);
        currentTokenTransfer = TokenTransfer({
            sender:_from,
            value:_value
        });
        require(this.delegatecall(_data));
        delete currentTokenTransfer;
    }
    
    function getPrice(bytes32 productId)
    public
    constant
    returns(uint price){
        return products[productId].price;
    }
    
    function getSeller()
    public
    constant
    returns(address _seller){
        return seller;
    }
    
    function stringToUint(string s) constant returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }else{
                if(c==46)
                    break;
            }
        }
    }
    
}





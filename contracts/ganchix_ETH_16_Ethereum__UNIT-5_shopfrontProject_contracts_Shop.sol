pragma solidity ^0.4.4;

import "./Killable.sol";
import "./Administrable.sol";


contract Shop is Killable, Administrable {

    struct Product {
        uint price;
        string name;
        uint stockBalance;
        uint index;
        bool exists;
    }

    mapping (address => uint) public pendingWithdrawals;

    mapping (uint => Product) stock;
    
    uint[] products;
    
    event AddProductEvent(uint id, uint price, string name, uint stockBalance);
    
    event DeleteProductEvent(uint id);
    
    event BuyProductEvent(uint id, address main);

    event LogWithdrawEvent(address main, uint quantity);

    function Shop(address administratorAddress) Administrable(administratorAddress)
        public
    {   
    }

    modifier existsProduct(uint id, bool value) 
    {
        require(stock[id].exists == value);
        _;
    }
    
    function getProductCount() 
        constant 
        public
        returns (uint length) 
    {   
        return products.length; 
    }

    function getProductIdAt(uint index)
        constant
        public
        returns (uint id) 
    {
        return products[index];
    }

    function getProduct(uint id)
        constant
        public
        returns (string name, uint price, uint stockBalance) 
    {
        Product storage product = stock[id];
        return (product.name,
            product.price,
            product.stockBalance);
    }
    
    function addProduct(uint id, uint price, string name, uint stockBalance)
        public 
        isAdministrator
        isNotKilled
        isNotPaused
        returns(bool success)
    {
        products.push(id);
        stock[id].price = price;
        stock[id].stockBalance = stockBalance;
        stock[id].name = name;
        stock[id].index = products.length - 1;
        AddProductEvent(id, price, name, stockBalance);
        return true;
    }
    
    function deleteProduct(uint id) 
        public 
        isAdministrator
        isNotKilled
        isNotPaused
        returns(bool success)
    {

        uint index = stock[id].index;
        delete stock[id];
        delete products[index];
        products.length--;
        DeleteProductEvent(id);
        return true;

    }

    function buyProduct(uint id) 
        payable
        isNotKilled
        isNotPaused
        public
        returns(bool success)
    {    
        require(stock[id].price > 0);
        require(stock[id].price <= msg.value);
        require(stock[id].stockBalance > 0);
        
        stock[id].stockBalance--;
        pendingWithdrawals[owner] += stock[id].price;
        
        if(msg.value > stock[id].price){
            uint payBackValue = (msg.value-stock[id].price);
            pendingWithdrawals[msg.sender] += payBackValue;
        }
        
        BuyProductEvent(id, msg.sender);
        return true;
    }
    


    function withdraw()
        isNotKilled
        isNotPaused
        public
        returns(bool success)
    {
        uint quantity = pendingWithdrawals[msg.sender];
        if (quantity<=0) revert(); 
            
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(quantity);
        LogWithdrawEvent(msg.sender, quantity);
        return true;
    }
}
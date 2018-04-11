pragma solidity ^0.4.11;

contract BuyerSeller {
    // global vars
    address creator;
    uint productId;

    // Structure for storage of Product details
    struct Product {
        string name;
        uint8 price;
    }

    // Mapping like a Database entry
    mapping (uint => Product) productIdMapping;
    mapping (address => uint[]) productListing;

    // Events to fire in success or failure
    event ProductAdded(uint id, string name, uint8 price);
    event ProductExists(uint id, string name, uint8 price);

    // Constructor for the Contract
    function BuyerSeller() {
        productId = 0x0;
        creator = msg.sender;
        // addProduct("Product1", 1);
        // addProduct("Product2",2);
    }

    // Listing Product for a seller
    function listProducts(address seller) constant returns (uint[] ids) {
        return productListing[seller];
    }

    // Getting Product by Identifier
    function getProductById(uint productId) constant returns(string, uint) {
        return (productIdMapping[productId].name, productIdMapping[productId].price);
    }

    // Getting Product Struct by Identifier
    function getProductStructById(uint productId) internal returns (Product) {
        return productIdMapping[productId];
    }

    // Adding a Product (Generic)
    function addProduct(string name, uint8 price) {
        productId++;
        productIdMapping[productId] = Product({name: name, price: price});
        productListing[msg.sender].push(productId);
        return ProductAdded(productId, name, price);
    }

    // Adding a Product at given Identifier
    function addProductAtId(uint id, string name, uint8 price) {
        // productId++;
        Product memory pr;
        if(productIdMapping[id].price == 0x0){
            productIdMapping[id] = Product({name: name, price: price});
            productListing[msg.sender].push(id);
            return ProductAdded(id, name, price);
        } else {
            pr = getProductStructById(id);
            return ProductExists(id, pr.name, pr.price);
        }
    }

    function kill() {
        if(msg.sender == creator) {
            selfdestruct(creator);
        }
    }
}

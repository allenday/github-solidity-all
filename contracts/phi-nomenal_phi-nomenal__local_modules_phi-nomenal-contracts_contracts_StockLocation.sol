pragma solidity ^0.4.6;
import './Product.sol';

contract StockLocation {
    string public location;
    Product[] public stock;

    function StockLocation(string location_) {
        location = location_;
    }

    function stockSize() constant returns (uint) {
        return stock.length;
    }

    function addStock(Product product) {
        stock.push(product);
    }
}

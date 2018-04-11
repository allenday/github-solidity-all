pragma solidity ^0.4.10;

contract brew2venue {
    enum beerType {lager, stout, porter, ipa}
    
    //Object to hold beer product, such as Newstead Brewery 21 Feet Seven Inches porter
    struct beer {
        address brewer;
        beerType beerType;
        string name;
        int ml;  //size of bottle / can in millilitres
        bytes32 sku;
    }
    
    function add (string _batch, int _abv)
    {
        beer memory _beer = beer (_batch, block.timestamp, _cost, _abv);
        bottles.push(_bottle);
    }
    
    //Add new product to the blockchain
    function newProduct(beerType _beerType, string _name, int _ml, bytes _sku)
    {
        beer memory _beer = beer (msg.sender, _beerTye, _name, _ml, _sku);
        _products(msg.sender).push(_beer);
    }
    
    beer [] public bottles;

    //Products per brewer
    mapping (address => bottle[]) _products;
}

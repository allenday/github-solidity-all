pragma solidity ^0.4.0;
contract OpenRetailContract {

    struct Product {
        address producer;
        bytes32 description_hash;
        string description_url;
        uint16 batch_quantity;
        string location;
    }
    
    struct ShippingBid {
        uint price;
        uint64 shipping_date;
        address shipper_id;
    }
    
    struct Customer {
        address customer_id;
        uint16 purchess_quantity;
        string shipping_address;
        string zip_code;
        string contact_info;
        ShippingBid winning_shipper;
        ShippingBid[] shippingBids;

    }
    
    Product private product;
    Customer[] private customers;
    
    function OpenRetailContract(uint16 batch_quantity,
                                bytes32 description_hash,
                                string description_url,
                                string location) 
    public {
        product.producer = msg.sender;
        product.batch_quantity = batch_quantity;
        product.description_hash = description_hash;
        product.location = location;
        product.description_url = description_url;
    }
    
    
    function get_description_url() public constant 
    returns(string){
        return product.description_url;
    }
    
    function get_location()  public constant 
    returns(string){
        return product.location;
    }
    
    
    function get_description_hash() public constant 
    returns(bytes32){
        return product.description_hash;
    }

    function get_total_quantity() public constant 
    returns(uint16){
        return product.batch_quantity;
    }

    function get_remaining_quantity() public constant 
    returns(uint16){
        uint16 purchesed_quantity = 0;
        for(uint16 i = 0; i < customers.length; i++){
            purchesed_quantity += customers[i].purchess_quantity;
        }
        return product.batch_quantity - purchesed_quantity;
    }
    
    function place_buy_order(uint16 quantity, string shipping_address, string zip_code, string contact_info) public {
        Customer new_customer;
        new_customer.customer_id = msg.sender;
        new_customer.shipping_address = shipping_address;
        new_customer.zip_code = zip_code;
        new_customer.contact_info = contact_info;
        
        customers.push(new_customer);
    }
    
}
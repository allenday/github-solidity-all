pragma solidity ^0.4.2;

import './GxOwnedInterface.sol';


contract GxOrderListInterface is GxOwnedInterface {
	
	// abstract functions
    function get(uint80 orderId) constant returns (
        uint80 _orderId, 
        uint80 next, 
        uint80 previous, 
        address account, 
        uint32 quantity, 
        uint32 originalQuantity, 
        uint32 pricePerCoin, 
        uint expirationTime
    );

    function add(
        uint80 previousOrderId, 
        uint80 orderId, 
        address account, 
        uint32 quantity, 
        uint32 originalQuantity, 
        uint32 pricePerCoin, 
        uint expirationTime
    ) returns (bool);

	function update(
        uint80 orderId, 
        address account, 
        uint32 quantity, 
        uint32 originalQuantity, 
        uint32 pricePerCoin, 
        uint expirationTime
    ) returns (bool);

    function getPricePerCoin(uint80 orderId) constant returns (uint32 pricePerCoin);
	function remove(uint80 orderId) returns (bool);
	function move(uint80 orderId, uint80 previousOrderId) public returns (bool);
	function consumeNextOrderId() public;
	function setNextOrderId(uint80 nextOrderId) public;
	
    uint80 public size;
    uint80 public first;
    uint80 public last;
    uint80 public nextOrderId;
}
// this is an abstract contract definition
// its purpose is to generate contract definition ABI so the 1.5.4 gxOrders contracts can be interacted with from JS script
// so it is here to get the old orders out of the contract

// it is not used in the actual contract definitions, this file is only referenced in migrate-methods.js script
contract gxOrders  {
    function getBuyOrder(uint80 orderId) public constant returns (uint80 _orderId, uint80 nextByPrice, address account, uint32 quantity, uint32 pricePerCoin, uint32 originalQuantity, uint expirationTime);
    function getSellOrder(uint80 orderId) public constant returns (uint80 _orderId, uint80 nextByPrice, address account, uint32 quantity, uint32 pricePerCoin, uint32 originalQuantity, uint expirationTime);
    function getBuyOrdersInfo() public constant returns (uint80 firstById, uint80 count, uint80 maxId);
    function getSellOrdersInfo() public constant returns (uint80 firstById, uint80 count, uint80 maxId);
}
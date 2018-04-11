pragma solidity ^0.4.2;

import './GxOrderListInterface.sol';
import './GxOwned.sol';
import './GxEditable.sol';


// GxOrderList is a doubly-linked list implementation with data specific to Gx Buy/Sell orders
// This is a purely a data contract and the the only methods are there to maintain list's links
// It implements basic CRUD methods (add, get, update, remove) and also has a "nextOrderId" counter
//
// This contract is a 'GxOwned' contract so any methods that modify the data can only be called by the 'owners'
// Owners can be managed by calling isOwner/addOwner/removeOrder methods that are defined in GxOwned.sol
contract GxOrderList is GxOrderListInterface, GxEditable, GxOwned {
    uint80 public size;
    uint80 public first;
    uint80 public last;
    uint80 public nextOrderId;

    struct Order {
        uint80 orderId;
        address account;
        uint32 quantity;
        uint32 originalQuantity;
        uint32 pricePerCoin;
        uint expirationTime;
    
        uint80 previous;
        uint80 next;
    }

    mapping(uint80 => Order) orders;
    
    function GxOrderList(address deploymentAdminsAddress) 
        GxEditable()
        GxOwned(deploymentAdminsAddress) 
    {
        isEditable = true;        
        nextOrderId = 1;
    }

    function get(uint80 orderId) constant returns (
        uint80 _orderId, 
        uint80 next, 
        uint80 previous, 
        address account, 
        uint32 quantity, 
        uint32 originalQuantity, 
        uint32 pricePerCoin, 
        uint expirationTime
    ) {
        Order memory order = orders[orderId];
        return (
            order.orderId,
            order.next,
            order.previous,
            order.account,
            order.quantity,
            order.originalQuantity,
            order.pricePerCoin,
            order.expirationTime);
    }

    function getPricePerCoin(uint80 orderId) constant returns (uint32 pricePerCoin) {
        Order memory order = orders[orderId];
        return order.pricePerCoin;
    }

    // adds an order to the list
    // the order is inserted after order specified by 'previousOrderId'
    // if 'previousOrderId' is 0, then the order is inserted at the front of the list
    function add(
        uint80 previousOrderId, 
        uint80 orderId, 
        address account, 
        uint32 quantity, 
        uint32 originalQuantity, 
        uint32 pricePerCoin, 
        uint expirationTime
    ) 
        public 
        callableWhenEditable 
        callableByOwner 
        returns (bool)
    {
        // see if the order already exists
        Order order = orders[orderId];
        // check if an order with this orderId already exists
        // cannot insert with same orderId
        if (order.orderId != 0x0) {
            return false;
        }

        order.orderId = orderId;
        order.account = account;
        order.quantity = quantity;
        order.originalQuantity = originalQuantity;
        order.pricePerCoin = pricePerCoin;
        order.expirationTime = expirationTime;

        // the link method links the order with previous/next order
        link(previousOrderId, order);

        // make sure the next order id is always bigger than the biggest orderId in the list
        if (orderId >= nextOrderId) {
            nextOrderId = orderId + 1;
        }

        // grow the size
        size++;
        return true;
    }

    // update an order without changing it's position in the list
    function update(
        uint80 orderId, 
        address account, 
        uint32 quantity, 
        uint32 originalQuantity, 
        uint32 pricePerCoin, 
        uint expirationTime
    ) 
        public 
        callableWhenEditable
        callableByOwner
        returns (bool) 
    {
        Order order = orders[orderId];
        // do not allow to update if the order doesn't exist
        if (order.orderId == 0x0) {
            return false;
        }

        order.account = account;
        order.quantity = quantity;
        order.originalQuantity = originalQuantity;
        order.pricePerCoin = pricePerCoin;
        order.expirationTime = expirationTime;

        return true;
    }

    // removes an order from the list
    function remove(uint80 orderId) 
        public 
        callableWhenEditable 
        callableByOwner 
        returns (bool)
    {
        Order order = orders[orderId];
        if (order.orderId == 0x0) {
            return false;
        }

        // the unlink method links the previous and next items together
        unlink(order);

        // decrease the size
        size--;
        // delete the order
        delete orders[orderId];
        return true;
    }

    // this method allows to change the position of an item in the list
    function move(uint80 orderId, uint80 previousOrderId) 
        public 
        callableWhenEditable 
        callableByOwner 
        returns (bool) 
    {
        Order order = orders[orderId];
        if (order.orderId == 0x0) {
            return false;
        }

        // order is already in the right place, no need to move
        if (order.previous == previousOrderId) {
            return true;
        }

        // use same code as add/remove
        // this is easier to understand than actually trying to change the links in a single method
        unlink(order);
        link(previousOrderId, order);

        return true;
    }

    // this allows to "consume" an orderId. 
    // An example case is when an order is created and matched fully
    // it doesn't get a chance to be inserted into orders list, but the orderId is "used up"
    function consumeNextOrderId() 
        public 
        callableWhenEditable 
        callableByOwner 
    {
        nextOrderId = nextOrderId + 1;
    }

    // this method allows to reset the nextOrderId
    // note that it is possible to set the nextOrderId to an existing orderId, so care must be used
    function setNextOrderId(uint80 _nextOrderId) 
        public 
        callableWhenEditable 
        callableByOwner 
    {
        nextOrderId = _nextOrderId;
    }

    /******** private methods **************/

    // this method "removes" the order from the list by unlinking it from previous/next
    // and linking the previous/next items together
    // does not actually delete the order!
    function unlink(Order order) private {
        var orderId = order.orderId;

        if (size <= 1) {
            first = 0x0;
            last = 0x0;
        }
        else if (orderId == first) {
            first = order.next;
            orders[first].previous = 0x0;
        }
        else if (orderId == last) {
            last = order.previous;
            orders[last].next = 0x0;
        }
        else {
            var previous = order.previous;
            var next = order.next;

            orders[previous].next = next;
            orders[next].previous = previous;
        }
    }

    // inserts an order into the list after 'previousOrderId'
    // if 'previousOrderId' is 0 then the order is inserted at the beginning of the list
    function link(uint80 previousOrderId, Order storage order) private {
        var orderId = order.orderId;

        // in an empty list, the order becomes both first and last
        if (size == 0) {
            first = orderId;
            last = orderId;

            order.previous = 0;
            order.next = 0;
        }
        else if (previousOrderId == 0) {
            // insert at the front
            // current first order becomes next of this order
            orders[first].previous = orderId;

            order.next = first;
            order.previous = 0;
            
            // set order as first
            first = orderId;
        }
        else {
            // insert in the middle or end
            // so in addition to previousOrderId, get the nextOrderId
            var nextOrderId = orders[previousOrderId].next;

            order.next = nextOrderId;
            order.previous = previousOrderId;

            // point the previous order to this order            
            orders[previousOrderId].next = orderId;

            // if inserting at the end, update the last to point to this order 
            if (nextOrderId == 0) {
                last = orderId;
            }
            else {
                // otherwise, we are inserting in the middle
                // so point the next order to point back at this order
                orders[order.next].previous = orderId;
            }
        }
    }

    // this only exists for compatibility with currently deployed contracts
    function upgradeDeploymentAdmins(address newDeploymentAdmins) public callableByDeploymentAdmin {
        deploymentAdmins = GxAccountsInterface(newDeploymentAdmins);
    }
}
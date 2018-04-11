import {Exchange, Custodian} from './Exchange.sol';

contract SimpleCustodian is Custodian {
    address authorized;
    Exchange public exchange;
    mapping(address => uint) available;
    mapping(address => uint) reserved;

    function SimpleCustodian() {
        authorized = msg.sender;
        exchange = new Exchange();
    }

    function give(address owner, uint amount) {
        if (msg.sender != authorized && msg.sender != address(exchange)) {
            throw;
        }
        available[owner] += amount;
    }

    function getAvailableBalance(address owner) returns (uint) {
        return available[owner];
    }

    function getReservedBalance(address owner) returns (uint) {
        return reserved[owner];
    }

    function reserve(address owner, uint amount) {
        if (msg.sender != authorized && msg.sender != address(exchange)) {
            throw;
        }
        if (available[owner] < amount) {
            throw;
        }
        available[owner] -= amount;
        reserved[owner] += amount;
    }

    function unreserve(address owner, uint amount) {
        if (msg.sender != authorized && msg.sender != address(exchange)) {
            throw;
        }
        if (reserved[owner] < amount) {
            throw;
        }
        reserved[owner] -= amount;
        available[owner] += amount;
    }

    function transfer(address oldOwner, address newOwner, uint shares) {
        if (msg.sender != authorized && msg.sender != address(exchange)) {
            throw;
        }
        if (available[oldOwner] < shares) {
            throw;
        }
        available[oldOwner] -= shares;
        available[newOwner] += shares;
    }
}

pragma solidity ^0.4.8;

contract Shipia {

    address owner;
    address buyer;
    address seller;
    ContractStatus status;
    uint price;
    string description;
    address billOwner;
    mapping(address => UserRole) roles;

    enum UserRole {Unknown, Buyer, Seller, Shipping}
    enum ContractStatus {Unknown,Draft, Initialized, Accepted, Shipped, Done}

    modifier ownerOnly {
        if(msg.sender != owner) throw;
        _;
    }

    modifier billOwnerOnly(address addr) {
        if(addr != billOwner) throw;
        _;
    }

    modifier roleOnly(address addr, UserRole role) {
        if(roles[addr] != role) throw;
        _;
    }

    function Shipia() {
        status = ContractStatus.Draft;
    }

    function reset() ownerOnly {
        status = ContractStatus.Unknown;
        price = 0;
        billOwner = 0x0;
        description = "";

    }

    function initSale(address _seller, address _buyer, uint _price, string cargoDescription) roleOnly(_buyer, UserRole.Buyer) roleOnly(msg.sender, UserRole.Seller) {
        if(msg.sender != _seller) throw;
        if(status != ContractStatus.Draft) throw;
        price = _price;
        description = cargoDescription;
        status = ContractStatus.Initialized;
        buyer = _buyer;
        seller = _seller;
    }

    function acceptSale() payable roleOnly(msg.sender, UserRole.Buyer) {
        if(msg.value < price) throw;
        if(msg.value > price) {
            if(!msg.sender.send(msg.value - price)){
                throw;
            }
        }
        status = ContractStatus.Accepted;
    }

    function createBill(address _billOwner) roleOnly(msg.sender, UserRole.Shipping) roleOnly(_billOwner, UserRole.Seller) {
        billOwner = _billOwner;
        status = ContractStatus.Shipped;
    }

    function transferBill(address transferTo) billOwnerOnly(msg.sender) {
        billOwner = transferTo;
    }

    function withdraw() {
        if(roles[msg.sender] == UserRole.Seller) {
            if(status == ContractStatus.Shipped && roles[billOwner] == UserRole.Buyer) {
                if(!msg.sender.send(this.balance)){
                    throw;
                }
                status = ContractStatus.Done;
            }
        }
    }

    function getPrice() constant returns (uint) {
        return price;
    }

    function getDescription() constant returns (string) {
        return description;
    }

    function setRole(address user, UserRole role) {
        roles[user] = role;
    }

    function getRole(address user) constant returns (UserRole) {
        return roles[user];
    }

    function getContractStatus() constant returns(ContractStatus) {
        return status;
    }

    function getBillOwner() constant returns (address) {
        return billOwner;
    }

    function getOwner() constant returns (address) {
        return owner;
    }

    function getBuyer() constant returns (address) {
       return buyer;
    }

    function getSeller() constant returns (address) {
        return seller;
    }

    function setOwner(address newOwner) {
        if(owner == 0x0 || owner == msg.sender) {
            owner = newOwner;
        }
    }
}

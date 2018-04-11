contract Escrow {
    struct Buyer {
        address account;
    }
    struct Seller {
        address account;
    }
    Buyer buyer;
    Seller seller;
    uint amount;
    uint dispute_resolution_fee = 5; //Percentage
    
    function setBuyer(uint _amount) {
        buyer.account = msg.sender;
        amount = _amount;
    }
    
    function setSeller(uint _amount) {
        seller.account = msg.sender;
        amount = _amount;
    }
    
    function getBuyer() constant returns (address buyerAccount) {
        return buyer.account;
    }
    
    function getSeller() constant returns (address sellerAccount) {
        return seller.account;
    }
    
    function complete() {
        seller.account.send(amount);
    }
    
    function cancel() {
        suicide(buyer.account);
    }
}

//This contract will create the Escrow contract for the users
contract EscrowCreator {
    function createEscrowBySeller(address seller, uint amount) returns (address tokenAddress) {
        Escrow contract = new Escrow();
        contract.setSeller(seller, amount)
        return address(contract);
    }
    
    function createEscrowByBuyer(address buyer, uint amount) returns (address tokenAddress) {
        Escrow contract = new Escrow();
        contract.setBuyer(buyer, amount)
        return address(contract);
    }
    
    function setArbitratorI(address arbitrator) {
    }
}
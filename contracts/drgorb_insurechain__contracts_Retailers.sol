pragma solidity ^0.4.4;

contract owned {
    address owner;

    modifier ownerOnly() {
        if (msg.sender == owner) _;
        throw;
    }

    function Owned() {
        owner = msg.sender;
    }
}

contract mortal is owned {
    enum Status {Requested, Accepted, Rejected, Terminated}

    function kill() {
        if (msg.sender == owner) selfdestruct(owner);
    }
}

contract Retailers is mortal {

    struct PartnerRelations {
        Status status;
        uint sales /*the total amount of policies sold by retailer*/;
        uint payments /*the total amount paid by retailer*/;
    }

    struct Retailer {
        string companyName;
        mapping (address=>PartnerRelations) partnerRelations /*the mapping holds the relation of the partner with each insurance company*/;
    }

    mapping (address=>Retailer) retailers;
    mapping (uint=>address) retailerList;
    uint retailersCount;

    event RetailerRequest(
        string indexed companyName,
        address retailerAddress,
        address indexed insurance
    );

    event StatusChanged(
        address indexed retailer,
        address indexed insurance,
        Status status
    );

    /**
    the retailer send a transaction to request registration with an insurer
    */
    function requestRegistration(string companyName, address insurance) returns (bool){
        Retailer retailer = retailers[msg.sender];
        retailer.companyName = companyName;
        retailer.partnerRelations[insurance].status = Status.Requested;
        /*only store retailers which have not been stored before*/
        if(bytes(retailers[msg.sender].companyName).length == 0)
            retailerList[retailersCount++] = msg.sender;

        retailers[msg.sender] = retailer;
        RetailerRequest(companyName, msg.sender, insurance);
        return true;
    }

    function getRequestStatus(address retailer, address insurance) constant returns(Status){
        return retailers[retailer].partnerRelations[insurance].status;
    }

    /**
    sets the status of a retailer's request.
    only the insurance to which the request was made can do this
    */
    function setRequestStatus(address retailer, Status status) {
        retailers[retailer].partnerRelations[msg.sender].status = status;
        StatusChanged(retailer, msg.sender, status);
    }

    function getRetailer(uint index) constant returns (address, string, Status) {
        return (retailerList[index], "titi", Status.Requested);
    }

}
pragma solidity ^0.4.11;

import "./mortal.sol";

/// @title Storage for Pass, Visa and Visa Offerings
/// version 0.7
contract Storage is owned, mortal {

    string constant public version = "0.7.0";

    // Access right variables
    address public citizen;
    address public country;
    address public immigration;
    address public embassy;

    // Modifiers
    modifier only(bool citizens, bool countries, bool immigrations, bool embassies) {
        if (citizens) { require(msg.sender == citizen); }
        if (countries) { require(msg.sender == country); }
        if (immigrations) { require(msg.sender == immigration); }
        if (embassies) { require(msg.sender == embassy); }
        _;
    }

    // Set Access right variables
    function setCitizen(address _citizen) onlyOwner() {
        citizen = _citizen;
    }

    function setCountry(address _country) onlyOwner() {
        country = _country;
    }

    function setImmigration(address _immigration) onlyOwner() {
        immigration = _immigration;
    }

    function setEmbassy(address _embassy) onlyOwner() {
        embassy = _embassy;
    }


    // Actual contract logic
    struct Passport {
        address owner;
        uint country;
        bytes32 hashedPassport;
        bool valid;
    }

    mapping (address => Passport) public passByOwner;

    function updatePassport(address _owner, uint _country, bytes32 _hashedPassport, bool _valid) {
        passByOwner[_owner] = Passport({
            owner: _owner,
            country: _country,
            hashedPassport: _hashedPassport,
            valid: _valid
        });
    }

    //-------

    struct VisaOffering {
        uint country; // as ISO 3166-1 numeric code
        bytes32 identifier;
        bytes32 description;
        uint validity; // in # of blocks
        uint price;    // in wei
        bytes32 conditions; // dummy string for conditions - will be extended with logic
    }

    /**
     * Get visa offering as following:
     * visaOfferings(address country)
     * @return VisaOffering
     */
    mapping (uint => VisaOffering[]) public visaOfferings;

    function createVisaOffering(uint _country, bytes32 _identifier, bytes32 _description,
                                uint _validity, uint _price, bytes32 _conditions) {
        visaOfferings[_country].push(VisaOffering({
            country: _country,
            identifier: _identifier,
            description: _description,
            validity: _validity,
            price: _price,
            conditions: _conditions
        }));
    }

    function visaOfferingsLength(uint _country) constant returns (uint) {
        return visaOfferings[_country].length;
    }

    function deleteVisaOffering(uint _country, uint index) {
        delete visaOfferings[_country][index];
    }

    //--------------//
    //     Visa     //
    //--------------//

    struct Visa {
        bytes32 identifier;
        uint amountPaid;
        uint price;
        uint entered; // highest block # when entering country
        uint left;    // highest block # when leaving country
    }

    /** Gets all the visa assigned to a citizen */
    // access with visaStore(ownerAddress, countryId, visaIndex) returns Visa
    mapping (address => mapping (uint => Visa[])) public visaStore;

    /**
     * Creates a new visa and returns the index of the visa
     */
    function visaLength(address _owner, uint _country) constant returns (uint) {
       return visaStore[_owner][_country].length;
    }

    function createVisa(address _owner, uint _country, bytes32 _identifier, uint _price) {
        visaStore[_owner][_country].push(Visa({
            identifier: _identifier,
            amountPaid: 0,
            price: _price,
            entered: 0,
            left: 0
        }));
    }

    function updateVisa(address _owner, uint _country, uint _visaId, bytes32 _identifier,
                        uint _amountPaid, uint _price, uint _entered, uint _left)  {
        visaStore[_owner][_country][_visaId] = Visa({
            identifier: _identifier,
            amountPaid: _amountPaid,
            price: _price,
            entered: _entered,
            left: _left
        });
    }
}

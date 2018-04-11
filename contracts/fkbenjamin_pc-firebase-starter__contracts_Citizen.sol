pragma solidity ^0.4.0;

import "./mortal.sol";
import "./Storage.sol";

/// @title Citizen
/// version 0.4
/// A country has citizens which can obtain passports and apply for visa.
contract Citizen is owned, mortal {

    // All data is stored centrally in a storage contract so it can be accessed
    // by all entities.
    address public usedStorage;

    struct Visa {
        address owner;
        uint country; // as ISO 3166-1 numeric code
        bytes32 identifier;
        uint amountPaid;
        uint price;
        uint entered; // highest block # when entering country
        uint left;    // highest block # when leaving country
    }

    function Citizen(address _usedStorage) {
        usedStorage = _usedStorage;
    }

    function setStorage(Storage _usedStorage) onlyOwner() {
        usedStorage = _usedStorage;
    }

    /**
     * Everybody can create a passport which is initially invalid
     */
    function createPassport(uint countryId, bytes32 hashedPass) {
        Storage(usedStorage).updatePassport(msg.sender, countryId, hashedPass, false);
    }

    /**
     * Creates a visa by provided visaOffering of msg.sender
     */
    function applyForVisa(uint _country, uint _index) {
        // TODO: Can only apply if has valid passport
        var (,i,,,p,) = Storage(usedStorage).visaOfferings(_country, _index);
        bytes32 _identifier = bytes32(i);
        uint _price = uint(p);
        Storage(usedStorage).createVisa(msg.sender,_country,_identifier,_price);
    }

    /**
     * Pay for a given visa of the owner
     */
    function payVisa(uint _country, uint _visaId) payable {
        var (i,a,p,e,l) = Storage(usedStorage).visaStore(msg.sender, _country, _visaId);
        address _owner = msg.sender;
        bytes32 _identifier = bytes32(i);
        uint _amountPaid = uint(a);
        uint _price = uint(p);
        uint _entered = uint(e);
        uint _left = uint(l);

        _amountPaid += msg.value;

        Storage(usedStorage).updateVisa(_owner,
                            _country,
                            _visaId,
                            _identifier,
                            _amountPaid,
                            _price,
                            _entered,
                            _left);
    }

}

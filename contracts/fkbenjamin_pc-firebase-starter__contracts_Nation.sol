pragma solidity ^0.4.11;

import "./mortal.sol";

import "./Immigration.sol";
import "./Embassy.sol";

/// @title Nation
/// version 0.5
contract Nation is owned, mortal {

    mapping (address => uint) public countries;
    address public immigrationCtrl;
    address public embassyCtrl;

    function Nation(address _immigrationCtrl, address _embassyCtrl) {
        immigrationCtrl = _immigrationCtrl;
        embassyCtrl = _embassyCtrl;
    }

    /// Sets the contract that handles all the immigration logic
    function setImmigrationCtrl(address _immigrationCtrl) onlyOwner() {
        immigrationCtrl = _immigrationCtrl;
    }

    /// Sets the contract that handles all the embassy logic
    function setEmbassyCtrl(address _embassyCtrl) onlyOwner() {
        embassyCtrl = _embassyCtrl;
    }

    /// Set the address that represents a country account
    function addCountry(address country, uint countryId) onlyOwner() {
        require(country != 0x0 && countryId != 0);
        countries[country] = countryId;
    }

    /// Adds a new immigration of a country
    function addImmigration(address immigration) {
        uint countryId = countries[msg.sender];
        require(immigration != 0x0);
        require(immigrationCtrl != 0x0);
        require(countryId != 0);
        Immigration(immigrationCtrl).addImmigrationOfCountry(immigration, countryId);
    }

    /// Adds a new embassy of a country
    function addEmbassy(address embassy) {
        uint countryId = countries[msg.sender];
        require(embassy != 0x0);
        require(embassyCtrl != 0x0);
        require(countryId != 0);
        Embassy(embassyCtrl).addEmbassyOfCountry(embassy, countryId);
    }

    /// Not yet implemented in immigration
    /*function removeImmigration(address immigration) returns (bool) {
        uint countryId = countries[msg.sender];
        if (immigration != 0x0 && immigrationCtrl != 0x0 && countryId != 0) {
            Immigration(immigrationCtrl).removeImmigrationOfCountry(immigration, countryId);
            return true;
        }
        return false;
    }*/

    /// Not yet implemented in embassy
    /*function removeEmbassy(address embassy) returns (bool) {
        uint countryId = countries[msg.sender];
        if (embassy != 0x0 && embassyCtrl != 0x0 && countryId != 0) {
            Embassy(embassyCtrl).removeEmbassyOfCountry(embassy, countryId);
            return true;
        }
        return false;
    }*/
}

pragma solidity ^0.4.11;
import "./mortal.sol";
import "./Storage.sol";

/// @title Immigration
/// The immigration acts as a the border patrol. Citizens passing Immigration
/// have to provide a valid visa. The visa will be stamped when entering and
/// leaving the country
contract Immigration is owned, mortal {
    string constant public version = "0.8.0";

    address public usedStorage;
    address public nationCtrl;

    struct Visa {
        address owner;
        uint country; // as ISO 3166-1 numeric code
        bytes32 identifier;
        uint amountPaid;
        uint price;
        uint entered; // highest block # when entering country
        uint left;    // highest block # when leaving country
    }

    mapping (address => uint) public immigrationOfCountry;

    modifier onlyImmigration() {
        require(immigrationOfCountry[msg.sender] != 0);
        _;
    }

    modifier onlyNation() {
        require(msg.sender == nationCtrl);
        _;
    }

    function Immigration(address _usedStorage, address _nationCtrl) {
        if (_usedStorage != 0x0) {usedStorage = _usedStorage;}
        if (_nationCtrl != 0x0) {nationCtrl = _nationCtrl;}
    }

    function setStorage(address _store) onlyOwner() returns (bool) {
        usedStorage = _store;
        return true;
    }

    function setNation(address _nation) onlyOwner() returns (bool) {
        nationCtrl = _nation;
        return true;
    }

    function addImmigrationOfCountry(address _immigration, uint _country) onlyNation() {
        immigrationOfCountry[_immigration] = _country;
    }

    function getVisaIdentifier(address _user, uint _country, uint _arrayPosition) onlyImmigration() returns(
        bytes32 _identifier
        )
    {
        var(c,,,,) = Storage(usedStorage).visaStore(_user, _country, _arrayPosition);
        _identifier = bytes32(c);
    }

    function getVisaAmountPaid(address _user, uint _country, uint _arrayPosition) onlyImmigration() returns(
        uint _amountPaid
        )     {
        var(,d,,,) = Storage(usedStorage).visaStore(_user, _country, _arrayPosition);
        _amountPaid = uint(d);
    }
    function getVisaPrice(address _user, uint _country, uint _arrayPosition) onlyImmigration() returns(
        uint _price
        )     {
        var(,,e,,) = Storage(usedStorage).visaStore(_user, _country, _arrayPosition);
        _price = uint(e);
    }
    function getVisaEntered(address _user, uint _country, uint _arrayPosition) onlyImmigration() returns(
        uint _entered
        )     {
        var(,,,f,) = Storage(usedStorage).visaStore(_user, _country, _arrayPosition);
        _entered = uint(f);
    }
    function getVisaLeft(address _user, uint _country, uint _arrayPosition) onlyImmigration() returns(
        uint _left
        )     {
        var(,,,,g) = Storage(usedStorage).visaStore(_user, _country, _arrayPosition);
        _left = uint(g);
    }


    function stampIn(address _owner, uint _country, uint _visaId) {
        // Visa wasn't used so far
        require(getVisaEntered(_owner,_country,_visaId) == 0);

        // Visa has to be paid
        uint _amountPaid = getVisaAmountPaid(_owner,_country,_visaId);
        require(_amountPaid >= getVisaPrice(_owner, _country, _visaId));

        Storage(usedStorage).updateVisa(
            _owner,
            _country,
            _visaId,
            getVisaIdentifier(_owner, _country, _visaId),
            _amountPaid,
            getVisaPrice(_owner, _country, _visaId),
            now,
            0
        );
    }

    function stampOut(address _owner, uint _country, uint _visaId) {
        uint entered = getVisaEntered(_owner,_country,_visaId);

        // Visa was used for Entry
        require(entered > 0);

        // Person has to be entered in the past
        require(entered < now);

        // Visa wasn't used for exit
        require(getVisaLeft(_owner,_country,_visaId) == 0);

        Storage(usedStorage).updateVisa(
            _owner,
            _country,
            _visaId,
            getVisaIdentifier(_owner, _country, _visaId),
            getVisaAmountPaid(_owner,_country,_visaId),
            getVisaPrice(_owner, _country, _visaId),
            entered,
            now
        );
    }
}

pragma solidity ^0.4.17;

/**
 * @title PayrollDB
 * @dev This contract acts as a simple key-value database for Payroll. We want
 * to split data and logic, also decouple contract api and data.
 */

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


contract PayrollDB is Ownable {

    using SafeMath for uint;

    uint256 public round;
    address[] public allowedContracts;
    mapping (uint256 => mapping (address => bool)) public isAllowedContract;

    mapping(bytes32 => uint) UIntStorage;
    mapping(bytes32 => address) AddressStorage;
    mapping(bytes32 => bool) BooleanStorage;

    modifier onlyAllowedContractOrOwner() {
        require(isAllowedContract[round][msg.sender] || msg.sender == owner);
        _;
    }

    function getAllowedContractsCount()
        external view returns (uint256)
    {
        return allowedContracts.length;
    }

    function setAllowedContract(address[] _contracts)
        onlyOwner
        external
    {
        require(validContracts(_contracts));

        round += 1;
        allowedContracts = _contracts;

        for (uint j = 0; j < _contracts.length; j++) {
            isAllowedContract[round][_contracts[j]] = true;
        }
    }

    function addAllowedContracts(address[] _contracts)
        onlyOwner
        external
    {
        require(validContracts(_contracts));

        for (uint i = 0; i < _contracts.length; i++) {
            allowedContracts.push(_contracts[i]);
            isAllowedContract[round][_contracts[i]] = true;
        }
    }

    function validContracts(address[] _contracts)
        private pure returns (bool)
    {
        for (uint i = 0; i < _contracts.length; i++) {
            if (_contracts[i] == 0x0) {
                return false;
            }
        }

        return true;
    }

    // ================
    // uint operations
    // ================

    function getUIntValue(bytes32 key)
        external view returns (uint)
    {
        return UIntStorage[key];
    }

    function setUIntValue(bytes32 key, uint value)
        onlyAllowedContractOrOwner
        external
    {
        UIntStorage[key] = value;
    }

    function delUIntValue(bytes32 key)
        onlyAllowedContractOrOwner
        external
    {
        delete UIntStorage[key];
    }

    function addUIntValue(bytes32 key, uint value)
        onlyAllowedContractOrOwner
        external returns (uint)
    {
        UIntStorage[key] = UIntStorage[key].add(value);
        return UIntStorage[key];
    }

    function subUIntValue(bytes32 key, uint value)
        onlyAllowedContractOrOwner
        external returns (uint)
    {
        UIntStorage[key] = UIntStorage[key].sub(value);
        return UIntStorage[key];
    }

    function mulUIntValue(bytes32 key, uint value)
        onlyAllowedContractOrOwner
        external returns (uint)
    {
        UIntStorage[key] = UIntStorage[key].mul(value);
        return UIntStorage[key];
    }

    function divUIntValue(bytes32 key, uint value)
        onlyAllowedContractOrOwner
        external returns (uint)
    {
        UIntStorage[key] = UIntStorage[key].div(value);
        return UIntStorage[key];
    }

    // ================
    // address operations
    // ================

    function getAddressValue(bytes32 key)
        external view returns (address)
    {
        return AddressStorage[key];
    }

    function setAddressValue(bytes32 key, address value)
        onlyAllowedContractOrOwner
        external
    {
        AddressStorage[key] = value;
    }

    function delAddressValue(bytes32 key)
        onlyAllowedContractOrOwner
        external
    {
        delete AddressStorage[key];
    }

    // ================
    // bool operations
    // ================

    function getBooleanValue(bytes32 record)
        external view returns (bool)
    {
        return BooleanStorage[record];
    }

    function setBooleanValue(bytes32 record, bool value)
        onlyAllowedContractOrOwner
        external
    {
        BooleanStorage[record] = value;
    }

    function deleteBooleanValue(bytes32 record)
        onlyAllowedContractOrOwner
        external
    {
        delete BooleanStorage[record];
    }

}

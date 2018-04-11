/// @title TruAddress
/// @dev Tru Address - Library of helper functions surrounding the Address type in Solidity
/// @author Ian Bray
pragma solidity 0.4.18;

import "./SafeMath.sol";


library TruAddress {
    
    using SafeMath for uint256;
    using SafeMath for uint;

    /// @dev Function to validate that a supplied Address is valid 
    /// (that is is 20 bytes long and it is not empty or 0x0)
    /// @return Returns true if the address is structurally a valid ethereum address and not 0x0; 
    /// returns false otherwise
    function isValid(address input) public pure returns (bool) {
        uint addrLength = addressLength(address(input));
        return ((addrLength == 20) && (input != address(0)));
    }

    /// @dev Function convert a Address to a String
    /// @return Address as a string
    function toString(address input) internal pure returns (string) {
        bytes memory byteArray = new bytes(20);
        for (uint i = 0; i < 20; i++) {
            byteArray[i] = byte(uint8(uint(input) / (2**(8*(19 - i)))));
        }
        return string(byteArray);
    }

    /// @dev Function to return the length of a given Address
    /// @return Length of the address as a uint
    function addressLength(address input) internal pure returns (uint) {
        string memory addressStr = toString(input);
        return bytes(addressStr).length;
    }
}
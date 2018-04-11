pragma solidity ^0.4.15;

import '../../installed_contracts/zeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @title Whitelist
 * @dev The Whitelist contract has one or mutiple whitelist addresses, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 *
 * Created by IaM <DEV> (Elky Bachtiar) 
 * https://www.iamdeveloper.io
 *
 *
 * file: Whitelist.sol
 * location: ERC23/contracts/ownership/
 *
 */
contract Whitelist is Ownable{
    
    uint256 public maxAddresses = 5;
    mapping (address => bool) public isWhitelisted;
    address[] public whitelists;
    event WhitelistRemoval(address indexed whitelist);
    event WhitelistAddition(address indexed whitelist);
    
    /**
    * @dev The Whitelist constructor sets the whitlisted addresses of the contract to the sender
    * account.
    * @param _whitelists List of initial whitelisted addresses.
    */
    function Whitelist(address[] _whitelists, uint256 _maxAddresses) {
        for (uint256 i = 0; i < _whitelists.length; i++) {
            require(!isWhitelisted[_whitelists[i]]);
            require(_whitelists[i] != 0);
            isWhitelisted[_whitelists[i]] = true;
        }
        whitelists = _whitelists;
        maxAddresses = _maxAddresses;
    }

    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier addressWhitelisted(address _whitelist) {
        assert(isWhitelisted[_whitelist]);
        _;
    }

    modifier addressNotWhitelisted(address _whitelist) {
        assert(!isWhitelisted[_whitelist]);
        _;
    }

    /// @dev Returns Whitelists.
    /// @return List of whitelist addresses.
    function getWhitelists() public constant returns (address[]) {
        return whitelists;
    }

    function checkWhitelisted(address _whitelist) public addressWhitelisted(_whitelist) returns (bool found){
        return true;
    }

    function setMaxAddresses(uint256 _maxAddresses) 
        public
        onlyOwner
        returns (bool success) 
    {
        require(_maxAddresses > 0);
        maxAddresses = _maxAddresses;
        return true;
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param _whitelist Address of new whitelist address.
    function addAddressToWhitelist(address _whitelist)
        public
        onlyOwner
        addressNotWhitelisted(_whitelist)
        returns (bool success)
    {
        require(_whitelist != 0);

        isWhitelisted[_whitelist] = true;
        whitelists.push(_whitelist);
        WhitelistAddition(_whitelist);
        return true;
    }

    /// @dev Allows to remove an address. Transaction has to be sent by wallet.
    /// @param _whitelist Address of whitelisted list.
    function removeAddressFromWhitelist(address _whitelist) 
        public
        onlyOwner
        //addressWhitelisted(_whitelist)
        returns (bool success)
    {
        isWhitelisted[_whitelist] = false;
        for (uint256 i = 0; i < whitelists.length - 1; i++) {
            if (whitelists[i] == _whitelist) {
                whitelists[i] = whitelists[whitelists.length - 1];

                break;
            }
            whitelists.length -= 1;
            WhitelistRemoval(_whitelist);
        }
        return true;
    }
}

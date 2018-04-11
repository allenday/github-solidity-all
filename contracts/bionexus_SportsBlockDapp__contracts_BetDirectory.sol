pragma solidity ^0.4.0;

/// @title Bet Directory Contract
/// @author The Sport Block Team


/// @notice The bet directory contains an array of bet contract
/// addresses
contract BetDirectory
{
    Bet[] availableBetContracts;

    // Address referring to the bet contracts.
    // Currently importing Bet.sol and using Bet as data type
    // throws some weird error.
    address contractOwner;

    /// @notice create a new directory and make
    /// the creator the contract owner
    function BetDirectory()
    {
        contractOwner = msg.sender;
    }

    /// @notice adds a bet contract to the list of contracts
    /// @dev This function returns a betContract. It's purpose is to
    /// allow you to fetch the game description and the time of
    /// the beginning of the game so you can show it on the website,
    /// for expample. However, betContracts that have destroyed themselves
    /// will still be listed here.
    /// @param betContractAddress Address of the contract to add
    function addBet(address betContractAddress)
    {
        if(msg.sender == contractOwner)
        {
            availableBetContracts.push(betContractAddress);
        }
    }

    /// @notice returns a the contract with the given id
    /// @param id the id of the contract you want to get
    function getBetById(uint id) returns(address betContract)
    {
        if(id >= availableBetContracts.length) throw;
        return availableBetContracts[id];
    }


}

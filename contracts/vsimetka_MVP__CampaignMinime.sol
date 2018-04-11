pragma solidity ^0.4.6;

import "MiniMeToken.sol";


contract Owned {
    /// Prevents methods from perfoming any value transfer
    modifier noEther() {if (msg.value > 0) throw; _; }
    /// Allows only the owner to call a function
    modifier onlyOwner { if (msg.sender != owner) throw; _; }

    address owner;

    function Owned() { owner = msg.sender;}



    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }

    function getOwner() noEther constant returns (address) {
        return owner;
    }
}


/// @title CampaignToken Contract
/// @author Jordi Baylina
/// @dev This is designed to control the ChairtyToken contract.

contract Campaign is TokenController, Owned {

    uint public startFundingTime;       // In UNIX Time Format
    uint public endFundingTime;         // In UNIX Time Format
    uint public maximumFunding;         // In wei
    uint public totalCollected;         // In wei
    MiniMeToken public tokenContract;  // The new token for this Campaign
    address public vaultAddress;       // The address to hold the funds donated

/// @notice 'Campaign()' initiates the Campaign by setting its funding
/// parameters and creating the deploying the token contract
/// @dev There are several checks to make sure the parameters are acceptable
/// @param _startFundingTime The UNIX time that the Campaign will be able to
/// start receiving funds
/// @param _endFundingTime The UNIX time that the Campaign will stop being able
/// to receive funds
/// @param _maximumFunding In wei, the Maximum amount that the Campaign can
/// receive (currently the max is set at 10,000 ETH for the beta)
/// @param _vaultAddress The address that will store the donated funds
/// @param _tokenAddress Address of the token contract

    function Campaign(
        uint _startFundingTime,
        uint _endFundingTime,
        uint _maximumFunding,
        address _vaultAddress,
        address _tokenAddress
    ) {
        if ((_endFundingTime < now) ||                // Cannot start in the past
            (_endFundingTime <= _startFundingTime) ||
            (_maximumFunding > 10000 ether) ||        // The Beta is limited
            (_vaultAddress == 0))                    // To prevent burning ETH
            {
            throw;
            }
        startFundingTime = _startFundingTime;
        endFundingTime = _endFundingTime;
        maximumFunding = _maximumFunding;
        tokenContract = MiniMeToken(_tokenAddress); // Deploys the Token Contract
        vaultAddress = _vaultAddress;
    }

/// @dev The fallback function is called when ether is sent to the contract, it
/// simply calls `doPayment()` with the address that sent the ether as the
/// `_owner`. Payable is a required solidity modifier for functions to receive
/// ether, without this modifier they will throw

    function ()  payable {
        doPayment(msg.sender);
    }

/////////////////
// TokenController interface
/////////////////

/// @notice `proxyPayment()` allows the caller to send ether to the Campaign and
/// have the CampaignTokens created in an address of their choosing
/// @param _owner The address that will hold the newly created CampaignTokens

    function proxyPayment(address _owner) payable returns(bool) {
        doPayment(_owner);
        return true;
    }

/// @notice Notifies the controller about a transfer
/// @param _from The origin of the transfer
/// @param _to The destination of the transfer
/// @param _amount The amount of the transfer
/// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) returns(bool) {
        return true;
    }

/// @notice Notifies the controller about an approval
/// @param _owner The address that calls `approve()`
/// @param _spender The spender in the `approve()` call
/// @param _amount The ammount in the `approve()` call
/// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool)
    {
        return true;
    }


/// @dev `doPayment()` is an internal function that sends the ether that this
/// contract receives to the `vault` and creates campaignTokens in the
/// address of the `_owner` assuming the Campaign is still accepting funds
/// @param _owner The address that will hold the newly created CampaignTokens

    function doPayment(address _owner) internal {

// First we check that the Campaign is allowed to receive this donation
        if ((now<startFundingTime) ||
            (now>endFundingTime) ||
            (tokenContract.controller() == 0) ||           // Extra check
            (msg.value == 0) ||
            (totalCollected + msg.value > maximumFunding))
        {
            throw;
        }

//Track how much the Campaign has collected
        totalCollected += msg.value;

//Send the ether to the vault
        if (!vaultAddress.send(msg.value)) {
            throw;
        }

// Creates an equal amount of CampaignTokens as ether sent. The new CampaignTokens
// are created in the `_owner` address
        if (!tokenContract.generateTokens(_owner, msg.value)) {
            throw;
        }

        return;
    }

/// @notice `finalizeFunding()` ends the Campaign by calling removing himself
/// as a controller.
/// @dev `finalizeFunding()` can only be called after the end of the funding period.

    function finalizeFunding() {
        if (now < endFundingTime) throw;
        tokenContract.changeController(0);
    }

////////////
// Initial import from the old token
////////////

    bool public sealed;


    function fill(uint[] data) onlyOwner {
        if (sealed)
            throw;

        for (uint i=0; i< data.length; i+= 2) {
            address dth = address(data[i]);
            uint amount = uint(data[i+1]);
            if (!tokenContract.generateTokens(dth, amount)) {
                throw;
            }
            totalCollected += amount;
        }
    }

    function seal() {
        if (sealed)
            throw;

        sealed= true;
    }

    function setVault(address _newVaultAddress) onlyOwner {
        vaultAddress = _newVaultAddress;
    }

}

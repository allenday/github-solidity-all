pragma solidity ^0.4.8;

import "MiniMeToken.sol";
import "Congress.sol";

contract MeDao is TokenController {
    
    string public Version = 'Matriarch_0.0.5';
    
    address public ceo; //The beneficiary and figure head of this contract 
    address public vault; //Ether collected during the ico is sent here
    address public curator; //Training wheels that can be removed later
    
    MiniMeToken public tokens;
    Congress public congress;
    
    uint public MAX_PURCHASABLE_TOKEN_SUPPLY;
    uint public PURCHASED_TOKEN_SUPPLY;
    bool public PURCHASABLE_TOKEN_SUPPLY_CAPPED = false;
    bool public TRANSFERS_ALLOWED = true;
    
////////////////
// Constructor and Default Function
////////////////

    function MeDao (
        address _ceo,
        address _curator,
        address _vault,
        address _MiniMeToken,
        address _Congress,
        uint _MAX_PURCHASABLE_TOKEN_SUPPLY
    ) {
        ceo = _ceo;
        curator = _curator;
        vault = _vault;
        tokens = MiniMeToken(_MiniMeToken);
        congress = Congress(_Congress);
        
        MAX_PURCHASABLE_TOKEN_SUPPLY = _MAX_PURCHASABLE_TOKEN_SUPPLY;
        PURCHASABLE_TOKEN_SUPPLY_CAPPED = false;
        TRANSFERS_ALLOWED = true;
    }
    
    function () payable {
        if(!proxyPayment(msg.sender))
            throw;
    }
    
////////////////
// Token Controller Functions
////////////////
    
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) payable returns(bool) {
        if(PURCHASABLE_TOKEN_SUPPLY_CAPPED)
            return false;
        
        if(PURCHASED_TOKEN_SUPPLY >= MAX_PURCHASABLE_TOKEN_SUPPLY)
            return false;
            
        uint remaining_tokens = MAX_PURCHASABLE_TOKEN_SUPPLY - PURCHASED_TOKEN_SUPPLY;
        uint amount_to_generate = msg.value;
        if(amount_to_generate > remaining_tokens){
            uint difference = amount_to_generate - remaining_tokens;
            if(!msg.sender.send(difference))
                return false;
                
            amount_to_generate = remaining_tokens;
            PURCHASABLE_TOKEN_SUPPLY_CAPPED = true;
        }
        
        PURCHASED_TOKEN_SUPPLY += amount_to_generate;
    
        tokens.generateTokens(_owner,amount_to_generate);
        if(!vault.send(amount_to_generate))
            throw;
        
        return true;
    }

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) returns(bool) {
        bool UNLOCKED = congress.isVoterLocked(_from);
        return (TRANSFERS_ALLOWED && UNLOCKED);
    }

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount) returns(bool) {
        bool UNLOCKED = congress.isVoterLocked(_owner);
        return (TRANSFERS_ALLOWED && UNLOCKED);
    }
    
////////////////
// Congress Controller Functions
//////////////// 
    
    /// @notice Called when `_voter` votes on a proposal in the Congress Contract
    /// @param _voter The address that sent a vote to a proposal
    /// @return Uint token balance of the '_voter'
    function getWeight(address _voter) returns(uint) {
        return tokens.balanceOf(_voter);
    }

    /// @notice Notifies the controller about a proposal passing
    /// @param _proposal_id The id of the proposal that passed
    function passed(uint _proposal_id) isCongress returns(bool) {
        bytes32 action = congress.getProposalAction(_proposal_id);
        if(action == 'updateMatriarch'){
            address updatedMatriarch = congress.getProposalAddress(_proposal_id);
            tokens.changeController(updatedMatriarch);
            
            NewController_event(updatedMatriarch);
        } else if(action == 'generateTokens'){
            address owner =  congress.getProposalAddress(_proposal_id);
            uint amount =  congress.getProposalUint(_proposal_id);
            tokens.generateTokens(owner, amount);
        }
    }
    
////////////////
// Curator Functions
////////////////
    
    function toggleTransfers() isCurator {
        //This will require token holder approval in the future
        TRANSFERS_ALLOWED = !TRANSFERS_ALLOWED;
        tokens.enableTransfers(TRANSFERS_ALLOWED);
        
        TransfersToggled_event(TRANSFERS_ALLOWED);
    }
    
    function easyUpdateMatriarch(address newAddress) isCurator {
        tokens.changeController(newAddress);
        NewController_event(newAddress);
    }

////////////////
// Modifiers
////////////////
    
    modifier isCurator { 
        if(msg.sender != curator)
            throw;
        _;
    }
    
    modifier isCongress { 
        if(msg.sender != address(congress) )
            throw;
        _;
    }
    
////////////////
// Events
////////////////

    event NewController_event(address newController);
    event NewCongress_event(address newCongress);
    event TransfersToggled_event(bool allowed);
    
}
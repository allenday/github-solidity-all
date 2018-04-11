/*
file:   AssetBackedTokens.sol
ver:    0.0.1
updated:15-July-2017
authors: Nick Addison

An ERC20 compliant asset-backed token.

The contract was based off Darryl Morris's ERC 20 token contract
https://github.com/o0ragman0o/ERC20/blob/master/ERC20.sol

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.
*/

pragma solidity ^0.4.10;

contract AssetBackedTokens
{
/* Constants */
    bytes32 constant public VERSION = "0.0.1";

/* Structs */
    struct TokenAccount
    {
        // available tokens to the token holder
        uint availableTokens;

        // asset holder of the token holder
        address assetHolder;
        
        // the amount someone else is allowed to transfer from this token holder
        mapping (address => uint) allowed;

        // flag to indicate if the struct has been initialised. Set to true if it has, otherwise it'll return false
        bool initialised;
    }
    
    struct AssetAccount
    {
        // the balance of the asset holder's assets held on deposit with the settlement institution
        uint settledAssets;

        // the amount of assets that is to be deposited or withdrawn from the asset holder's account the next time the settlement process is run
        int unsettledAssets;
        
        // total amount of tokens issued to token holders by this asset holder
        uint issuedTokens;

        // flag to indicate if the struct has been initialised. Set to true if it has, otherwise it'll return false
        bool initialised;
    }

/* State Valiables */

    /// @return Token symbol
    string public symbol;

    /// @return Token symbol
    uint8 public decimals;

    // Externally owned account (token holder's address) mapped to the token account details
    mapping (address => TokenAccount) public tokenAccounts;
    
    // Maps asset holder addresses to assets held at the settlement institution
    // One asset holder can have multiple addresses mapped to a single account at the settlement institution
    mapping (address => AssetAccount) public assetAccounts;
    // list of participating asset holders
    address[] assetHolders;
    
    // externally owned account (identity) of the settlement insitituion
    address settlementInstitution;

    // externally owned account (identity) of the scheme administrator
    address administrator;

/* Enums */

/* Modifiers */
    // check that the sender of the transaction is the scheme administrator
    modifier onlyAdministrator {
        require(administrator == msg.sender);
        _;
    }

    // check that the sender of the transaction is the settlement asset holder
    modifier onlySettlementInstitution {
        require(settlementInstitution == msg.sender);
        _;
    }

    // is the transaction originator a registered asset holder?
    modifier onlyAssetHolders {
        require(assetAccounts[msg.sender].initialised);
        _;
    }

/* Events */
    // Triggered when tokens are transferred.
    event Transfer(
        address indexed sendingTokenHolder,
        address indexed receivingTokenHolder,
        uint amount);

    // Triggered whenever approve(address _spender, uint _amount) is called.
    event Approval(
        address indexed tokenHolder,
        address indexed thirdParty,
        uint amount);

    event EmitTokenTransfer(
        address indexed tokenHolder,
        int amount,                 // amount of tokens being increased (positive) or decreased (negative)
        uint availableTokens);      // token holder's available tokens after the update

    event EmitAssetTransfer(
        address assetHolder,
        int amount,                 // the amount of assets transfered to (positive) or from (negative) the asset holder
        int unsettledAssets,        // the asset holder's unsettled assets after the asset transfer
        uint issuedTokens);         // the asset holder's issued tokens after the asset transfer

    event EmitAssetUpdate(
        address indexed assetHolder,
        int amount,                 // amount of assets being increased (positive) or decreased (negative)
        int unsettledAssets);       // the asset holder's unsettled assets after the update

    event EmitTokenUpdate(
        address indexed assetHolder,
        address indexed tokenHolder,
        int amount,                 // amount of tokens being increased (positive) or decreased (negative)
        uint availableTokens,       // token holder's available tokens after the update
        uint issuedTokens);         // asset holder's issued tokens after the update
    
    event EmitAssetSettlement(
        address indexed assetHolder,
        int settledAssetsInTransaction, // the amount of assets settled for a asset holder. Can be a negative value
        uint newSettledAssetBalance);   // the asset holder's settled assets after the settlement

/* Funtions Public */

    // constructor
    function AssetBackedTokens(string _symbol, uint8 _decimals, address _settlementInstitution)
    {
        symbol = _symbol;
        decimals = _decimals;

        administrator = msg.sender;
        settlementInstitution = _settlementInstitution;
    }
    
    // balance of the token holder's available tokens
    function balanceOf(address _tokenHolder) public constant returns (uint)
    {
        return tokenAccounts[_tokenHolder].availableTokens;
    }
    
    // the amount of tokens a third party can transfer from a token holder
    function allowance(address tokenHolder, address thirdParty) public constant returns (uint)
    {
        return tokenAccounts[tokenHolder].allowed[thirdParty];
    }

    // transfers tokens from transaction originator to another token holder
    function transfer(address receivingTokenHolder, uint amount) external
    {
        xfer(msg.sender, receivingTokenHolder, amount);
    }

    // transfer tokens from one tokenHolder to another where the sending token holder has allowed the transaction originator
    function transferFrom(address sendingTokenHolder, address receivingTokenHolder, uint amount) external
    {
        require(tokenAccounts[sendingTokenHolder].allowed[msg.sender] >= amount);

        tokenAccounts[sendingTokenHolder].allowed[msg.sender] -= amount;

        xfer(sendingTokenHolder, receivingTokenHolder, amount);
    }

    // Process a transfer internally.
    function xfer(address sendingTokenHolder, address receivingTokenHolder, uint amount) internal
    {
        // check the sender has the available tokens
        require(amount > 0 && tokenAccounts[sendingTokenHolder].availableTokens >= amount);
        // the receiving token holder already has a token account
        require(tokenAccounts[receivingTokenHolder].initialised);

        var sendingAssetHolder = tokenAccounts[sendingTokenHolder].assetHolder;
        var receivingAssetHolder = tokenAccounts[receivingTokenHolder].assetHolder;

        tokenAccounts[sendingTokenHolder].availableTokens -= amount;
        tokenAccounts[receivingTokenHolder].availableTokens += amount;

        // check for overflow
        assert(tokenAccounts[receivingTokenHolder].availableTokens > amount);

        // if assets are being transferred between asset holders
        if (sendingAssetHolder != receivingAssetHolder)
        {
            transferAssets(sendingAssetHolder, receivingAssetHolder, amount);
        }

        // Emit event
        Transfer(sendingTokenHolder, receivingTokenHolder, amount);

        // Emit event for sending token holder
        EmitTokenTransfer(sendingTokenHolder, -int(amount), tokenAccounts[sendingTokenHolder].availableTokens);
        
        // Emit event for receiving token holder
        EmitTokenTransfer(receivingTokenHolder, int(amount), tokenAccounts[receivingTokenHolder].availableTokens);
    }

    function transferAssets(address sendingAssetHolder, address receivingAssetHolder, uint amount) internal onlySettlementInstitution
    {
        // the asset holder of the sending token holder has enough assets and issued tokens
        require(int(assetAccounts[sendingAssetHolder].settledAssets) + assetAccounts[sendingAssetHolder].unsettledAssets >= int(amount) );
        require(assetAccounts[sendingAssetHolder].issuedTokens >= amount);

        // decrease the assets for the sending asset holder
        assetAccounts[sendingAssetHolder].unsettledAssets -= int(amount);
        assetAccounts[sendingAssetHolder].issuedTokens -= amount;
        
        // increase the assets for the receiving asset holder
        assetAccounts[receivingAssetHolder].unsettledAssets += int(amount);
        assetAccounts[receivingAssetHolder].issuedTokens += amount;

        // check for overflows
        assert(assetAccounts[receivingAssetHolder].unsettledAssets > int(amount));
        assert(assetAccounts[receivingAssetHolder].issuedTokens > amount);

        // Emit events to the sending and receiving asset holders
        EmitAssetTransfer(sendingAssetHolder, int(-amount), assetAccounts[sendingAssetHolder].unsettledAssets, assetAccounts[sendingAssetHolder].issuedTokens);
        EmitAssetTransfer(receivingAssetHolder, int(amount), assetAccounts[receivingAssetHolder].unsettledAssets, assetAccounts[receivingAssetHolder].issuedTokens);
    }

    // Sets the amount of tokens a third-party can transfer from the token holder
    function approve(address thirdParty, uint amount) external
    {
        tokenAccounts[msg.sender].allowed[thirdParty] = amount;
        Approval(msg.sender, thirdParty, amount);
    }

    // the scheme administrator updates the settlement institution
    function updateSettlementInstitution(address newSettlementInstitutionAddress) onlyAdministrator
    {
        settlementInstitution = newSettlementInstitutionAddress;
    }

    // the settlement institution increases (deposit) or decreases (withdrawal) a asset holder's assets on deposit with them
    // a positive amount is a deposit, a negative amount is a withdrawal
    function updateAssets(address assetHolder, int amount) onlySettlementInstitution
    {
        // if a asset account does not already exist for the asset holder
        if (assetAccounts[assetHolder].initialised == false)
        {
            // create a new asset account for the asset holder
            assetAccounts[assetHolder] = AssetAccount(0, 0, 0, true);
            // add to the list of asset holders
            assetHolders.push(assetHolder);
        }

        // the asset holder's remaining assets is required to be greater than or equal to the tokens issued by the asset holder
        assert(
            int(assetAccounts[assetHolder].settledAssets) +
            assetAccounts[assetHolder].unsettledAssets +
            amount >= int(assetAccounts[assetHolder].issuedTokens) );

        // increase or decrease the unsettled assets
        assetAccounts[assetHolder].unsettledAssets += amount;
        
        if (amount > 0) {
            // check for overflow
            assert(assetAccounts[assetHolder].unsettledAssets > amount);
        } else {
            assert(assetAccounts[assetHolder].unsettledAssets > 0);
        }
        
        // Emit event for the update of the asset holder's unsettled assets
        EmitAssetUpdate(assetHolder, amount, assetAccounts[assetHolder].unsettledAssets);
    }

    // the settlement institution settles the assets between their asset holder accounts
    function settleAssets() onlySettlementInstitution
    {
        // for each asset holder
        for (uint i; i < assetHolders.length; i++)
        {
            var assetHolder = assetHolders[i];
            var unsettledAssets = assetAccounts[assetHolder].unsettledAssets;

            // if the asset holder has unsettled assets
            if (unsettledAssets != 0)
            {
                // increase or decrease the settled assets by the number of unsettled assets
                if (unsettledAssets > 0)
                {
                    assetAccounts[assetHolder].settledAssets += uint(unsettledAssets);

                    // check for overflows
                    assert(assetAccounts[assetHolder].settledAssets > uint(unsettledAssets));
                }
                else {
                    assert(assetAccounts[assetHolder].settledAssets >= uint(-unsettledAssets));

                    // convert the negative unsettled amount to a positive amount
                    assetAccounts[assetHolder].settledAssets -= uint(-unsettledAssets);
                }
                
                // reset the unsettled assets back to zero
                assetAccounts[assetHolder].unsettledAssets = 0;
                
                // emit event
                EmitAssetSettlement(assetHolder, unsettledAssets, assetAccounts[assetHolder].settledAssets);
            }
        }
    }

    // returns the asset balances of an asset holder
    function getAssetBalances(address assetHolder) constant returns (uint settledAssets, int unsettledAssets, uint issuedTokens)
    {
        require(assetAccounts[assetHolder].initialised);
        
        settledAssets = assetAccounts[assetHolder].settledAssets;
        unsettledAssets = assetAccounts[assetHolder].unsettledAssets;
        issuedTokens = assetAccounts[assetHolder].issuedTokens;
    }

    // asset holder increases or decreases the token holder's available tokens and their own number of issued tokens
    function updateTokens(address tokenHolder, int amount) onlyAssetHolders
    {
        require(amount != 0);

        // if the token account does not already exist
        if (tokenAccounts[tokenHolder].initialised == false)
        {
            tokenAccounts[tokenHolder] = TokenAccount(0, msg.sender, true);
        }

        // is the transaction originator the asset holder of the token holder?
        require(tokenAccounts[tokenHolder].assetHolder == msg.sender);

        address assetHolder = msg.sender;
        uint uintAmount;
        
        // if increasing (depositing) tokens
        if (amount > 0)
        {
            uintAmount = uint(amount);

            // the asset holder has enough assets held at the settlement institution to issue more
            // tokens to the asset holder's token holders
            assert(int(assetAccounts[assetHolder].settledAssets) +
                assetAccounts[assetHolder].unsettledAssets >= int(assetAccounts[assetHolder].issuedTokens) + amount);

            assetAccounts[assetHolder].issuedTokens += uintAmount;
            tokenAccounts[tokenHolder].availableTokens += uintAmount;

            // check for overflows
            assert(assetAccounts[assetHolder].issuedTokens > uintAmount);
            assert(tokenAccounts[tokenHolder].availableTokens > uintAmount);
        }
        // decreasing (withdrawing) tokens
        else if (amount < 0)
        {
            uintAmount = uint(-amount);

            // the token holder's available tokens is required to be greater than the amount of tokens being withdrawn
            assert(assetAccounts[assetHolder].issuedTokens >= uintAmount);
            assert(tokenAccounts[tokenHolder].availableTokens >= uintAmount);

            assetAccounts[assetHolder].issuedTokens -= uintAmount;
            tokenAccounts[tokenHolder].availableTokens -= uintAmount;
        }
        
        EmitTokenUpdate(
            assetHolder,
            tokenHolder,
            amount,                                     // amount of tokens
            tokenAccounts[tokenHolder].availableTokens, // updated value
            assetAccounts[assetHolder].issuedTokens);   // updated value
    }

    // removes any asset holders from the list of asset holders if they have zero asset balances
    // this is done peridically rather than inline as it is an expensive operation
    function cleanAssetHolders() returns (uint numberOfCleanedAssetHolders)
    {
        address[] storage newassetHolders;

        // for each asset holder
        for (uint i; i < assetHolders.length; i++)
        {
            var assetHolder = assetHolders[i];
            
            // if the asset holder no longer has any positive or negative balances
            if (assetAccounts[assetHolder].unsettledAssets == 0 &&
                assetAccounts[assetHolder].settledAssets == 0 &&
                assetAccounts[assetHolder].issuedTokens == 0)
            {
                // Do not add this old asset holder with zero balances to the list of new asset holders
                numberOfCleanedAssetHolders++;
            }
            else
            {
                // add the old asset holder into the list of new asset holders
                newassetHolders.push(assetHolder);
            }
        }

        assetHolders = newassetHolders;
    }

    // return list of asset holders
    function getAssetHolders() public constant returns (address[])
    {
        return assetHolders;
    }
}
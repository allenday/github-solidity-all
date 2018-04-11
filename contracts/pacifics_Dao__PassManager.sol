import "PassDao.sol";
import "PassTokenManager.sol";

pragma solidity ^0.4.8;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Manager smart contract is used for the management of the Dao account, shares and tokens.
 *
*/

/// @title Manager smart contract of the Pass Decentralized Autonomous Organisation
contract PassManager is PassTokenManager {
    
    struct order {
        address buyer;
        uint weiGiven;
    }
    // Orders to buy tokens
    order[] public orders;
    // Number or orders to buy tokens
    uint numberOfOrders;

    // Map to know if an order was cloned from the precedent manager after an upgrade
    mapping (uint => bool) orderCloned;
    
    function PassManager(
        PassDao _passDao,
        address _clonedFrom,
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals,
        bool _token,
        bool _transferable,
        uint _initialPriceMultiplier,
        uint _inflationRate) 
        PassTokenManager( _passDao, _clonedFrom, _tokenName, _tokenSymbol, _tokenDecimals, 
            _token, _transferable, _initialPriceMultiplier, _inflationRate) { }
    
    /// @notice Function to receive payments
    function () payable onlyShareManager { }
    
    /// @notice Function used by the client to send ethers
    /// @param _recipient The address to send to
    /// @param _amount The amount (in wei) to send
    /// @return Whether the transfer was successful or not
    function sendTo(
        address _recipient,
        uint _amount
    ) external onlyClient returns (bool) {

        if (_recipient.send(_amount)) return true;
        else return false;
    }

    /// @dev Internal function to buy tokens and promote a proposal 
    /// @param _proposalID The index of the proposal
    /// @param _buyer The address of the buyer
    /// @param _date The unix date to consider for the share or token price calculation
    /// @param _presale True if presale
    /// @return Whether the function was successful or not 
    function buyTokensFor(
        uint _proposalID,
        address _buyer, 
        uint _date,
        bool _presale) internal returns (bool) {

        if (_proposalID == 0 || !sale(_proposalID, _buyer, msg.value, _date, _presale)) throw;

        fundings[_proposalID].totalWeiGiven += msg.value;        
        if (fundings[_proposalID].totalWeiGiven == fundings[_proposalID].amountToFund) closeFunding(_proposalID);

        Given[_proposalID][_buyer].weiAmount += msg.value;
        
        return true;
    }
    
    /// @notice Function to buy tokens and promote a proposal 
    /// @param _proposalID The index of the proposal
    /// @param _buyer The address of the buyer (not mandatory, msg.sender if 0)
    /// @return Whether the function was successful or not 
    function buyTokensForProposal(
        uint _proposalID, 
        address _buyer) payable returns (bool) {

        if (_buyer == 0) _buyer = msg.sender;

        if (fundings[_proposalID].moderator != 0) throw;

        return buyTokensFor(_proposalID, _buyer, now, true);
    }

    /// @notice Function used by the moderator to buy shares or tokens
    /// @param _proposalID Index of the client proposal
    /// @param _buyer The address of the recipient of shares or tokens
    /// @param _date The unix date to consider for the share or token price calculation
    /// @param _presale True if presale
    /// @return Whether the function was successful or not 
    function buyTokenFromModerator(
        uint _proposalID,
        address _buyer, 
        uint _date,
        bool _presale) payable external returns (bool){

        if (msg.sender != fundings[_proposalID].moderator) throw;

        return buyTokensFor(_proposalID, _buyer, _date, _presale);
    }

    /// @dev Internal function to create a buy order
    /// @param _buyer The address of the buyer
    /// @param _weiGiven The amount in wei given by the buyer
    function addOrder(
        address _buyer, 
        uint _weiGiven) internal {

        uint i;
        numberOfOrders += 1;

        if (numberOfOrders > orders.length) i = orders.length++;
        else i = numberOfOrders - 1;
        
        orders[i].buyer = _buyer;
        orders[i].weiGiven = _weiGiven;
    }

    /// @dev Internal function to remove a buy order
    /// @param _order The index of the order to remove
    function removeOrder(uint _order) internal {
        
        if (numberOfOrders - 1 < _order) return;

        numberOfOrders -= 1;
        if (numberOfOrders > 0) {
            for (uint i = _order; i <= numberOfOrders - 1; i++) {
                orders[i].buyer = orders[i+1].buyer;
                orders[i].weiGiven = orders[i+1].weiGiven;
            }
        }
        orders[numberOfOrders].buyer = 0;
        orders[numberOfOrders].weiGiven = 0;
    }
    
    /// @notice Function to create orders to buy tokens
    /// @return Whether the function was successful or not
    function buyTokens() payable returns (bool) {

        if (!transferable || msg.value < 100 finney) throw;
        
        addOrder(msg.sender, msg.value);
        
        return true;
    }
    
    /// @notice Function to sell tokens
    /// @param _tokenAmount in tokens to sell
    /// @param _from Index of the first order
    /// @param _to Index of the last order
    /// @return the revenue in wei
    function sellTokens(
        uint _tokenAmount,
        uint _from,
        uint _to) returns (uint) {

        if (!transferable 
            || uint(balances[msg.sender]) < _amount 
            || numberOfOrders == 0) throw;
        
        if (_to == 0 || _to > numberOfOrders - 1) _to = numberOfOrders - 1;
        
        
        uint _tokenAmounto;
        uint _amount;
        uint _totalAmount;
        uint o = _from;

        for (uint i = _from; i <= _to; i++) {

            if (_tokenAmount > 0 && orders[o].buyer != msg.sender) {

                _tokenAmounto = TokenAmount(orders[o].weiGiven, priceMultiplier(0), actualPriceDivisor(0));

                if (_tokenAmount >= _tokenAmounto 
                    && transferFromTo(msg.sender, orders[o].buyer, _tokenAmounto)) {
                            
                    _tokenAmount -= _tokenAmounto;
                    _totalAmount += orders[o].weiGiven;
                    removeOrder(o);
                }
                else if (_tokenAmount < _tokenAmounto
                    && transferFromTo(msg.sender, orders[o].buyer, _tokenAmount)) {
                        
                    _amount = weiAmount(_tokenAmount, priceMultiplier(0), actualPriceDivisor(0));
                    orders[o].weiGiven -= _amount;
                    _totalAmount += _amount;
                    i = _to + 1;
                }
                else o += 1;
            } 
            else o += 1;
        }
        
        if (!msg.sender.send(_totalAmount)) throw;
        else return _totalAmount;
    }    

    /// @notice Function to remove your orders and refund
    /// @param _from Index of the first order
    /// @param _to Index of the last order
    /// @return Whether the function was successful or not
    function removeOrders(
        uint _from,
        uint _to) returns (bool) {

        if (_to == 0 || _to > numberOfOrders) _to = numberOfOrders -1;
        
        uint _totalAmount;
        uint o = _from;

        for (uint i = _from; i <= _to; i++) {

            if (orders[o].buyer == msg.sender) {
                
                _totalAmount += orders[o].weiGiven;
                removeOrder(o);

            } else o += 1;
        }

        if (!msg.sender.send(_totalAmount)) throw;
        else return true;
    }
    
}    

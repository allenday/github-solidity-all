pragma solidity ^0.4.15;

import '../ownership/Ownable.sol';
import './SimpleTrade.sol';

/**
@title SimpleMarketplace
@dev This marketplace contract allows decentralized exchange of ERC20 Standard tokens for ETH.
 */
contract SimpleMarketplace is Ownable {

    event Deposit(address from, uint256 amount);
    event Withdraw(uint256 amount);
    event TokenRecovery(address token, address recipient, uint256 amount);

    /**
    @dev Standard compliant fallback function.
     */
    function() payable {
        Deposit(msg.sender, msg.value);
    }

    /**
    @dev Creates a trade contract for a seller.
    @param _token The token address
    @param _amount The amount of tokens to sell
    @param _price The price in wei for all the tokens
    @return the address of the custom trade contract
     */
    function createNewTrade(address _token, uint256 _amount, uint256 _price) returns (address) {
        return new SimpleTrade(msg.sender, _token, _amount, _price);
    }

    /**
    @dev Marketplace owner can withdraw eventual deposits.
     */
    function withdraw() onlyOwner {
        Withdraw(this.balance);
        owner.transfer(this.balance);
    }

    /**
    @dev Contract owner can send back stuck tokens sent directly to this contract by mistake.
    @param _token The token address
    @param _recipient The recipient address
    @param _amount The amount of tokens to send
     */
    function tokenRecovery(address _token, address _recipient, uint256 _amount) onlyOwner {
        require(_token.call(bytes4(sha3("transfer(address,uint256)")),_recipient, _amount));
        TokenRecovery(_token, _recipient, _amount);
    }

    /**
    @dev Contract owner can send back stuck tokens sent directly to a trade contract by mistake.
    @dev Seller must set the trade in recovery mode first.
    @param _trade The trade address
    @param _token The token address
    @param _recipient The recipient address
    @param _amount The amount of tokens to send
     */
    function tokenRecoveryFromTrade(address _trade, address _token, address _recipient, uint256 _amount) onlyOwner {
        SimpleTrade trade = SimpleTrade(_trade);
        require(trade.tokenRecovery(_token,_recipient,_amount));
        TokenRecovery(_token, _recipient, _amount);
    }

}
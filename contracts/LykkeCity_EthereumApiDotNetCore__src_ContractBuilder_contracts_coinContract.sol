pragma solidity ^0.4.9;
import "./coin.sol";
import "./token/erc20Contract.sol";

contract ColorCoin is Coin(0){

    address _externalTokenAddress;

    function ColorCoin(address exchangeContractAddress, address externalTokenAddress) Coin(exchangeContractAddress) { 
        _externalTokenAddress = externalTokenAddress;
    }

    function cashin(address receiver, uint amount) ownerOrTransferContract payable returns(bool){
        if (msg.value > 0) return false; 
        
        var userAddress = transferContractUser[receiver];

        coinBalanceMultisig[userAddress] += amount;

        CoinCashIn(userAddress, amount);
        
        return true;
    }

    // cashout coins (called only from exchange contract)
    function cashout(address from, address to, uint amount) onlyFromExchangeContract { 
        if (coinBalanceMultisig[from] < amount) {
            throw;
        }

        var erc20Token = ERC20Interface(_externalTokenAddress);
        var tokenBalance = erc20Token.balanceOf(this);

        if (tokenBalance < amount) {
            throw;
        }

        if (!erc20Token.transfer(to, amount)){
            throw;
        }

        coinBalanceMultisig[from] -= amount;

        CoinCashOut(msg.sender, from, amount, to);
    }
}
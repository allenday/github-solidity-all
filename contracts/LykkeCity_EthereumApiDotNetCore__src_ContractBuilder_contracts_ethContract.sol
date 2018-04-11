pragma solidity ^0.4.9;
import "./coin.sol";

contract EthCoin is Coin(0) {

    function EthCoin(address exchangeContractAddress) Coin(exchangeContractAddress) { }

    function cashin(address receiver, uint amount) ownerOrTransferContract payable returns(bool){
        var userAddress = transferContractUser[receiver];

        coinBalanceMultisig[userAddress] += msg.value;

        CoinCashIn(receiver, msg.value);
        
        return true;
    }

    function cashout(address client, address to, uint amount) onlyFromExchangeContract {
        if (coinBalanceMultisig[client] < amount) {
            throw;
        }

        if (!to.send(amount)) throw;

        coinBalanceMultisig[client] -= amount;

        CoinCashOut(msg.sender, client, amount, to);
    }
}
pragma solidity ^0.4.9;
import "./coin.sol";

contract MainExchangeNM {

    //private fields
    address _owner;
    uint _lastPing;
    mapping (uint => bool) public transactions;

    function MainExchangeNM() {
        _owner = msg.sender;
    }

    modifier onlyowner { if (msg.sender == _owner || (now - _lastPing) > 30 days) _; }

    function cashout(uint id, address coinAddress, address client, address to, uint amount, bytes client_sign, bytes params) onlyowner {
        
        if (transactions[id])
            throw;
            
        var coin_contract = Coin(coinAddress);
        coin_contract.cashout(client, to, amount);

        transactions[id] = true;
    }

    function transfer(uint id, address coinAddress, address from, address to, uint amount, bytes sign, bytes params) onlyowner {
        if (transactions[id])
            throw;

        _transferCoins(coinAddress, from, to, amount);
        transactions[id] = true; 
    }

    function transferWithChange(uint id, address coinAddress, address fromAddress, address toAddress, uint amount, uint change, bytes fromSign, bytes toSign, bytes params) onlyowner {
        if (transactions[id])
            throw;
        
        if (amount <= change) {
            throw;
        }

        uint amountMinusChange = amount - change;

        _transferCoins(coinAddress, fromAddress, toAddress, amountMinusChange);
        transactions[id] = true; 
    }

    // change coin exchange contract
    function changeMainContractInCoin(address coinContract, address newMainContract) onlyowner {
        var coin_contract = Coin(coinContract);
        coin_contract.changeExchangeContract(newMainContract);
    }

    function _transferCoins(address contractAddress, address from, address to, uint amount) private {
        var coin_contract = Coin(contractAddress);
        coin_contract.transferMultisig(from, to, amount);
    }

    function ping() onlyowner {
        _lastPing = now;
    }
}
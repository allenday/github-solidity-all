pragma solidity ^0.4.9;
import "./coin.sol";

contract MainExchange {

    //private fields
    address _owner;
    uint _lastPing;
    mapping (uint => bool) public transactions;

    function MainExchange() {
        _owner = msg.sender;
    }

    modifier onlyowner { if (msg.sender == _owner || (now - _lastPing) > 30 days) _; }

    // can be called only from contract owner (Is Lykke contract owner?)
    // create swap transaction signed by exchange and check client signs
    function swap(uint id, address client_a, address client_b, address coinAddress_a, address coinAddress_b, uint amount_a, uint amount_b, 
                bytes client_a_sign, bytes client_b_sign, bytes params) onlyowner returns(bool) {
        
        if (transactions[id])
            throw;

        bytes32 hash = sha3(id, client_a, client_b, coinAddress_a, coinAddress_b, amount_a, amount_b); 

        if (!_checkClientSign(client_a, hash, client_a_sign)) {
            throw;                    
        }
        if (!_checkClientSign(client_b, hash, client_b_sign)) {
            throw;
        }

        // trasfer amount_a in coin_a from client_a to client_b
        _transferCoins(coinAddress_a, client_a, client_b, amount_a);

        // trasfer amount_b in coin_b from client_b to client_a
        _transferCoins(coinAddress_b, client_b, client_a, amount_b);

        transactions[id] = true;

        return true;
    }

    function cashout(uint id, address coinAddress, address client, address to, uint amount, bytes client_sign, bytes params) onlyowner {
        
        if (transactions[id])
            throw;

        bytes32 hash = sha3(id, coinAddress, client, to, amount);
            
        if (!_checkClientSign(client, hash, client_sign)) {
            throw;                    
        }

        var coin_contract = Coin(coinAddress);
        coin_contract.cashout(client, to, amount);

        transactions[id] = true;
    }

    function transfer(uint id, address coinAddress, address from, address to, uint amount, bytes sign, bytes params) onlyowner {
        if (transactions[id])
            throw;

        bytes32 hash = sha3(id, coinAddress, from, to, amount);

        if (!_checkClientSign(from, hash, sign)) {
            throw;
        }

        _transferCoins(coinAddress, from, to, amount);
        transactions[id] = true; 
    }

    function transferWithChange(uint id, address coinAddress, address fromAddress, address toAddress, uint amount, uint change, bytes fromSign, bytes toSign, bytes params) onlyowner {
        if (transactions[id])
            throw;
        
        if (amount <= change) {
            throw;
        }

        bytes32 hashFrom = sha3(id, coinAddress, fromAddress, toAddress, amount);
        bytes32 hashTo = sha3(id, coinAddress, toAddress, fromAddress, change);

        if (!_checkClientSign(fromAddress, hashFrom, fromSign)) {
            throw;
        }

        if (!_checkClientSign(toAddress, hashTo, toSign)) {
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

    function _checkClientSign(address client_addr, bytes32 hash, bytes sig) private returns(bool) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := mload(add(sig, 65))
        }

        return client_addr == ecrecover(hash, v, r, s);
    }

    function ping() onlyowner {
        _lastPing = now;
    }
}
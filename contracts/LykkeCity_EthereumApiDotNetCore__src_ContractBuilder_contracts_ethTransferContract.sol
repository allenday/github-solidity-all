pragma solidity ^0.4.9;
import "./coin.sol";
import "./transferBaseContract.sol";

contract EthTransferContract is TransferBaseContract {

    modifier onlyowner { if (msg.sender == _owner) _; }

    function EthTransferContract(address coinAdapterAddress) TransferBaseContract(coinAdapterAddress) {        
    }

    function() payable {
    }

    function cashin() onlyowner {
        if (this.balance <= 0) {
            throw;
        }

        var coin_contract = Coin(_coinAdapterAddress);
        if (!coin_contract.cashin.value(this.balance)(this, this.balance)){
            throw;
        }
    }
}

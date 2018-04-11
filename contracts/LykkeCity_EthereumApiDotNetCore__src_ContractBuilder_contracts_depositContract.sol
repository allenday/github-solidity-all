pragma solidity ^0.4.9;
import "./coin.sol";
import "./transferBaseContract.sol";
import "./token/erc20Contract.sol";

contract DepositContract is DepositContract{

    address _externalTokenAddress;

    modifier onlyowner { if (msg.sender == _owner) _; }

    function TokenTransferContract(address coinAdapterAddress, address externalTokenAddress) 
        TransferBaseContract(coinAdapterAddress) {
            _externalTokenAddress = externalTokenAddress;
    }

    function cashin() onlyowner {
        var erc20Token = ERC20Interface(_externalTokenAddress);
        var tokenBalance = erc20Token.balanceOf(this);

        if (tokenBalance <= 0) {
            throw;
        }

        var coin_contract = Coin(_coinAdapterAddress);

        if (!erc20Token.transfer(_coinAdapterAddress, tokenBalance)) {
            throw;
        }
        
        if (!coin_contract.cashin(this, tokenBalance)) {
            throw;
        }
        
    }
}

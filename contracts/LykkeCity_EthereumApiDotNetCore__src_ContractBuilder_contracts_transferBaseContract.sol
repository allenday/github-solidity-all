pragma solidity ^0.4.9;

contract TransferBaseContract {
    address _owner;  
    address _coinAdapterAddress;

    modifier onlyowner { if (msg.sender == _owner) _; }

    function TransferBaseContract(address coinAdapterAddress) {        
        _owner = msg.sender;
        _coinAdapterAddress = coinAdapterAddress;
    }
}

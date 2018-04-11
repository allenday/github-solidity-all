/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;

import './adapters/MultiEventsHistoryAdapter.sol';
import './adapters/Roles2LibraryAndERC20LibraryAdapter.sol';
import './adapters/StorageAdapter.sol';
import './libs/SafeMath.sol';


contract ERC20BalanceInterface {
    function balanceOf(address _address) public view returns(uint);
}


contract BalanceHolderInterface {
    function deposit(address _from, uint _value, address _contract) public returns (bool);
    function withdraw(address _to, uint _value, address _contract) public returns (bool);
}

contract PaymentGateway is StorageAdapter, MultiEventsHistoryAdapter, Roles2LibraryAndERC20LibraryAdapter {

    using SafeMath for uint;

    uint constant PAYMENT_GATEWAY_SCOPE = 15000;
    uint constant PAYMENT_GATEWAY_INSUFFICIENT_BALANCE = PAYMENT_GATEWAY_SCOPE + 1;
    uint constant PAYMENT_GATEWAY_TRANSFER_FAILED = PAYMENT_GATEWAY_SCOPE + 2;
    uint constant PAYMENT_GATEWAY_NO_FEE_ADDRESS_DESTINATION = PAYMENT_GATEWAY_SCOPE + 3;


    event FeeSet(address indexed self, address indexed contractAddress, uint feePercent);
    event Deposited(address indexed self, address indexed contractAddress, address indexed by, uint value);
    event Withdrawn(address indexed self, address indexed contractAddress, address indexed by, uint value);
    event Transferred(address indexed self, address indexed contractAddress, address from, address indexed to, uint value);

    StorageInterface.Address balanceHolder;
    StorageInterface.AddressAddressUIntMapping balances; // contract => user => balance
    StorageInterface.Address feeAddress;
    StorageInterface.AddressUIntMapping fees; // 10000 is 100%.

    function PaymentGateway(
        Storage _store,
        bytes32 _crate,
        address _roles2Library,
        address _erc20Library
    )
    StorageAdapter(_store, _crate)
    Roles2LibraryAndERC20LibraryAdapter(_roles2Library, _erc20Library)
    public
    {
        balanceHolder.init('balanceHolder');
        balances.init('balances');
        feeAddress.init('feeAddress');
        fees.init('fees');
    }

    function setupEventsHistory(address _eventsHistory) auth external returns (uint) {
        require(_eventsHistory != 0x0);

        _setEventsHistory(_eventsHistory);
        return OK;
    }

    function setBalanceHolder(address _balanceHolder) auth external returns (uint) {  // only owner
        store.set(balanceHolder, _balanceHolder);
        return OK;
    }

    function setFeeAddress(address _feeAddress) auth external returns (uint) {  // only owner
        store.set(feeAddress, _feeAddress);
        return OK;
    }

    function setFeePercent(
        uint _feePercent,
        address _contract
    )
    auth  // only owner
    onlySupportedContract(_contract)
    external
    returns (uint) {
        require(_feePercent < 10000);

        store.set(fees, _contract, _feePercent);
        _emitFeeSet(_feePercent, _contract);
        return OK;
    }

    function getFeePercent(address _contract) public view returns (uint) {
        return store.get(fees, _contract);
    }

    function deposit(
        uint _value,
        address _contract
    )
    onlySupportedContract(_contract)
    public
    returns (uint)
    {
        require(_value > 0);

        if (getBalanceOf(msg.sender, _contract) < _value) {
            return _emitErrorCode(PAYMENT_GATEWAY_INSUFFICIENT_BALANCE);
        }

        BalanceHolderInterface _balanceHolder = getBalanceHolder();
        uint balanceBefore = getBalanceOf(_balanceHolder, _contract);
        if (!_balanceHolder.deposit(msg.sender, _value, _contract)) {
            return _emitErrorCode(PAYMENT_GATEWAY_TRANSFER_FAILED);
        }

        uint depositedAmount = getBalanceOf(_balanceHolder, _contract).sub(balanceBefore);
        store.set(balances, _contract, msg.sender, getBalance(msg.sender, _contract).add(depositedAmount));

        _emitDeposited(msg.sender, depositedAmount, _contract);
        return OK;
    }

    function withdraw(uint _value, address _contract) public returns (uint) {
        require(_value > 0);

        return _withdraw(msg.sender, _value, _contract);
    }

    function _withdraw(address _from, uint _value, address _contract) internal returns (uint) {
        if (getBalance(_from, _contract) < _value) {
            return _emitErrorCode(PAYMENT_GATEWAY_INSUFFICIENT_BALANCE);
        }

        BalanceHolderInterface _balanceHolder = getBalanceHolder();
        uint balanceBefore = getBalanceOf(_balanceHolder, _contract);
        if (!_balanceHolder.withdraw(_from, _value, _contract)) {
            return _emitErrorCode(PAYMENT_GATEWAY_TRANSFER_FAILED);
        }

        uint withdrawnAmount = balanceBefore.sub(getBalanceOf(_balanceHolder, _contract));
        store.set(balances, _contract, _from, getBalance(_from, _contract).sub(withdrawnAmount));

        _emitWithdrawn(_from, _value, _contract);
        return OK;
    }

    // Will be optimized later if used.
    function transfer(address _from, address _to, uint _value, address _contract) public returns (uint) {
        return transferWithFee(_from, _to, _value, _value, 0, _contract);
    }

    function transferWithFee(
        address _from,
        address _to,
        uint _value,
        uint _feeFromValue,
        uint _additionalFee,
        address _contract
    )
    public
    returns (uint)
    {
        address[] memory toArray = new address[](1);
        toArray[0] = _to;
        uint[] memory valueArray = new uint[](1);
        valueArray[0] = _value;
        return transferToMany(_from, toArray, valueArray, _feeFromValue, _additionalFee, _contract);
    }

    function transferToMany(
        address _from,
        address[] _to,
        uint[] _value,
        uint _feeFromValue,
        uint _additionalFee,
        address _contract
    )
    auth  // only payment processor
    onlySupportedContract(_contract)
    public
    returns (uint)
    {
        require(_from != 0x0);
        require(_to.length == _value.length);

        uint _total = 0;
        for (uint i = 0; i < _to.length; i++) {
            _addBalance(_to[i], _value[i], _contract);
            _emitTransferred(_from, _to[i], _value[i], _contract);
            _total = _total.add(_value[i]);
        }

        uint _fee = calculateFee(_feeFromValue, _contract).add(_additionalFee);
        address _feeAddress = getFeeAddress();
        if (_fee > 0 && _feeAddress != 0x0) {
            _addBalance(_feeAddress, _fee, _contract);
            _emitTransferred(_from, _feeAddress, _fee, _contract);
            _total = _total.add(_fee);
        }

        _subBalance(_from, _total, _contract);

        return OK;
    }

    function transferAll(
        address _from,
        address _to,
        uint _value,
        address _change,
        uint _feeFromValue,
        uint _additionalFee,
        address _contract
    )
    auth  // only payment processor
    onlySupportedContract(_contract)
    external
    returns (uint)
    {
        require(_from != 0x0);

        _addBalance(_to, _value, _contract);
        _emitTransferred(_from, _to, _value, _contract);

        uint _total = _value;
        uint _fee = calculateFee(_feeFromValue, _contract).add(_additionalFee);
        address _feeAddress = getFeeAddress();
        if (_fee > 0 && _feeAddress != 0x0) {
            _addBalance(_feeAddress, _fee, _contract);
            _emitTransferred(_from, _feeAddress, _fee, _contract);
            _total = _total.add(_fee);
        }

        uint _changeAmount = getBalance(_from, _contract).sub(_total);
        if (_changeAmount != 0) {
            _addBalance(_change, _changeAmount, _contract);
            _emitTransferred(_from, _change, _changeAmount, _contract);
            _total = _total.add(_changeAmount);
        }

        _subBalance(_from, _total, _contract);

        return OK;
    }

    function transferFromMany(
        address[] _from,
        address _to,
        uint[] _value,
        address _contract
    )
    auth  // only payment processor
    onlySupportedContract(_contract)
    external
    returns (uint)
    {
        require(_to != 0x0);
        require(_from.length == _value.length);

        uint _total = 0;
        for (uint i = 0; i < _from.length; i++) {
            _subBalance(_from[i], _value[i], _contract);
            _emitTransferred(_from[i], _to, _value[i], _contract);
            _total = _total.add(_value[i]);
        }

        _addBalance(_to, _total, _contract);

        return OK;
    }

    function forwardFee(uint _value, address _contract) public returns (uint) {
        require(_value > 0);

        address _feeAddress = getFeeAddress();
        if (_feeAddress == 0x0) {
            return _emitErrorCode(PAYMENT_GATEWAY_NO_FEE_ADDRESS_DESTINATION);
        }

        return _withdraw(_feeAddress, _value, _contract);
    }

    function getBalance(address _address, address _contract) public view returns(uint) {
        return store.get(balances, _contract, _address);
    }

    function getBalanceOf(address _address, address _contract) public view returns(uint) {
        return ERC20BalanceInterface(_contract).balanceOf(_address);
    }

    function calculateFee(uint _value, address _contract) public view returns(uint) {
        uint feeRaw = _value.mul(getFeePercent(_contract));
        return (feeRaw / 10000) + (feeRaw % 10000 == 0 ? 0 : 1);
    }

    function getFeeAddress() public view returns(address) {
        return store.get(feeAddress);
    }

    function getBalanceHolder() public view returns(BalanceHolderInterface) {
        return BalanceHolderInterface(store.get(balanceHolder));
    }


    // HELPERS

    function _addBalance(address _to, uint _value, address _contract) internal {
        require(_to != 0x0);
        require(_value > 0);

        store.set(balances, _contract, _to, getBalance(_to, _contract).add(_value));
    }

    function _subBalance(address _from, uint _value, address _contract) internal {
        require(_from != 0x0);
        require(_value > 0);

        store.set(balances, _contract, _from, getBalance(_from, _contract).sub(_value));
    }


    // EVENTS

    function _emitFeeSet(uint _feePercent, address _contract) internal {
        PaymentGateway(getEventsHistory()).emitFeeSet(_feePercent, _contract);
    }

    function _emitDeposited(address _by, uint _value, address _contract) internal {
        PaymentGateway(getEventsHistory()).emitDeposited(_by, _value, _contract);
    }

    function _emitWithdrawn(address _by, uint _value, address _contract) internal {
        PaymentGateway(getEventsHistory()).emitWithdrawn(_by, _value, _contract);
    }

    function _emitTransferred(address _from, address _to, uint _value, address _contract) internal {
        PaymentGateway(getEventsHistory()).emitTransferred(_from, _to, _value, _contract);
    }

    function emitFeeSet(uint _feePercent, address _contract) public {
        FeeSet(_self(), _contract, _feePercent);
    }

    function emitDeposited(address _by, uint _value, address _contract) public {
        Deposited(_self(), _contract, _by, _value);
    }

    function emitWithdrawn(address _by, uint _value, address _contract) public {
        Withdrawn(_self(), _contract, _by, _value);
    }

    function emitTransferred(address _from, address _to, uint _value, address _contract) public {
        Transferred(_self(), _contract, _from, _to, _value);
    }

}

/*
    token.sol
    1.0.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.15;

import "./safeMath.sol";
import "./module.sol";
import "./moduleHandler.sol";
import "./tokenDB.sol";
import "./thirdPartyContract.sol";

contract token is safeMath, module {
    /* module callbacks */
    function connectModule() external onlyForModuleHandler returns (bool success) {
        super._connectModule();
        return true;
    }
    function replaceModule(address addr) onlyForModuleHandler external returns (bool success) {
        require( db.replaceOwner(addr) );
        super._replaceModule(addr);
        return true;
    }
    function configureModule(announcementType aType, uint256 value, address addr) onlyForModuleHandler external returns(bool success) {
        if      ( aType == announcementType.transactionFeeRate )    { transactionFeeRate = value; }
        else if ( aType == announcementType.transactionFeeMin )     { transactionFeeMin = value; }
        else if ( aType == announcementType.transactionFeeMax )     { transactionFeeMax = value; }
        else if ( aType == announcementType.transactionFeeBurn )    { transactionFeeBurn = value; }
        else { return false; }
        super._configureModule(aType, value, addr);
        return true;
    }
    /* Variables */
    /**
    * @title Corion Platform Token
    * @author iFA @ Corion Platform
    */
    string  public name = "Corion";
    string  public symbol = "COR";
    uint8   public decimals = 6;
    tokenDB public db;
    uint256 public transactionFeeRate   = 20;
    uint256 public transactionFeeRateM  = 1e3;
    uint256 public transactionFeeMin    =   20000;
    uint256 public transactionFeeMax    = 5000000;
    uint256 public transactionFeeBurn   = 80;
    /* Constructor */
    function token(address moduleHandlerAddr, address dbAddr) module(moduleHandlerAddr) {
        /*
            Deploy function
            
            @forReplace                 This address will be replaced with the old one or not.
            @moduleHandlerAddr          Modulhandler's address
            @dbAddr                     Address of database
        */
        require( dbAddr != 0x00 );
        db = tokenDB(dbAddr);
    }
    /* Externals */
    /**
     * @notice `msg.sender` approves `spender` to spend `amount` tokens on its behalf.
     * @param spender The address of the account able to transfer the tokens
     * @param amount The amount of tokens to be approved for transfer
     * @param nonce The transaction count of the authorised address
     * @return True if the approval was successful
     */
    function approve(address spender, uint256 amount, uint256 nonce) readyModule external returns (bool success) {

        /*
            Authorise another address to use a certain quantity of the authorising owner’s balance
         
            @spender            Address of authorised party
            @amount             Token quantity
            @nonce              Transaction count
            
            @success            Was the Function successful?
        */
        _approve(spender, amount, nonce);
        return true;
    }
    /**
     * @notice `msg.sender` approves `spender` to spend `amount` tokens on its behalf and notify the spender from your approve with your `extraData` data.
     * @param spender The address of the account able to transfer the tokens
     * @param amount The amount of tokens to be approved for transfer
     * @param nonce The transaction count of the authorised address
     * @param extraData Data to give forward to the receiver
     * @return True if the approval was successful
     */
    function approveAndCall(address spender, uint256 amount, uint256 nonce, bytes extraData) readyModule external returns (bool success) {
        /*
            Authorise another address to use a certain quantity of the authorising  owner’s balance
            Following the transaction the receiver address `approvedCorionToken` function is called by the given data
            
            @spender            Authorized address
            @amount             Token quantity
            @extraData          Extra data to be received by the receiver
            @nonce              Transaction count
            
            @success            Was the Function successful?
        */
        _approve(spender, amount, nonce);
        require( checkContract(spender) );
        require( thirdPartyContract(spender).approvedToken(msg.sender, amount, extraData) );
        return true;
    }
    /**
     * @notice Send `amount` Corion tokens to `to` from `msg.sender`
     * @param to The address of the recipient
     * @param amount The amount of tokens to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address to, uint256 amount) readyModule external returns (bool success) {
        /*
            Start transaction, token is sent from caller’s address to receiver’s address
            Transaction fee is to be deducted.
            If receiver is not a natural address but a person, he will be called
          
            @to         To who
            @amount     Quantity
            
            @success    Was the Function successful?
        */
        bytes memory _data;
        if ( isContract(to) ) {
            _transferToContract(msg.sender, to, amount, _data);
        } else {
            _transfer( msg.sender, to, amount, true);
        }
        Transfer(msg.sender, to, amount, _data);
        return true;
    }
    /**
     * @notice Send `amount` tokens to `to` from `from` on the condition it is approved by `from`
     * @param from The address holding the tokens being transferred
     * @param to The address of the recipient
     * @param amount The amount of tokens to be transferred
     * @return True if the transfer was successful
     */
    function transferFrom(address from, address to, uint256 amount) readyModule external returns (bool success) {

        /*
            Start transaction to send a quantity from a given address to another address. (approve / allowance). This can be called only by the address approved in advance
            Transaction fee is to be deducted
            If receiver is not a natural address but a person, he will be called
            
            @from       From who.
            @to         To who
            @amount     Quantity
            
            @success    Was the Function successful?
        */
        if ( from != msg.sender ) {
            var (_success, _reamining, _nonce) = db.getAllowance(from, msg.sender);
            require( _success );
            _reamining = safeSub(_reamining, amount);
            _nonce = safeAdd(_nonce, 1);
            require( db.setAllowance(from, msg.sender, _reamining, _nonce) );
            AllowanceUsed(msg.sender, from, amount);
        }
        bytes memory _data;
        if ( isContract(to) ) {
            _transferToContract(from, to, amount, _data);
        } else {
            _transfer( from, to, amount, true);
        }
        Transfer(from, to, amount, _data);
        return true;
    }
    /**
     * @notice Send `amount` tokens to `to` from `from` on the condition it is approved by `from`
     * @param from The address holding the tokens being transferred
     * @param to The address of the recipient
     * @param amount The amount of tokens to be transferred
     * @return True if the transfer was successful
     */
    function transferFromByModule(address from, address to, uint256 amount, bool fee) readyModule external returns (bool success) {

        /*
            Start transaction to send a quantity from a given address to another address
            Only ModuleHandler can call it
           
            @from       From who
            @to         To who.
            @amount     Quantity
            @fee        Deduct transaction fee - yes or no?
            
            @success    Was the Function successful?
        */
        bytes memory _data;
        require( super.isModuleHandler(msg.sender) );
        _transfer( from, to, amount, fee);
        Transfer(from, to, amount, _data);
        return true;
    }
    /**
     * @notice Send `amount` Corion tokens to `to` from `msg.sender` and notify the receiver from your transaction with your `extraData` data
     * @param to The contract address of the recipient
     * @param amount The amount of tokens to be transferred
     * @param extraData Data to give forward to the receiver
     * @return Whether the transfer was successful or not
     */
    function transfer(address to, uint256 amount, bytes extraData) readyModule external returns (bool success) {

        /*
            Start transaction to send a quantity from a given address to another address
            After transaction the function `receiveCorionToken`of the receiver is called  by the given data
            When sending an amount, it is possible the total amount cannot be processed, the remaining amount is sent back with no fee charged
            
            @to             To who.
            @amount         Quantity
            @extraData      Extra data the receiver will get
            
            @success        Was the Function successful?
        */
        if ( isContract(to) ) {
            _transferToContract(msg.sender, to, amount, extraData);
        } else {
            _transfer( msg.sender, to, amount, true);
        }
        Transfer(msg.sender, to, amount, extraData);
        return true;
    }
    /**
     * @notice Transaction fee will be deduced from `owner` for transacting `value`
     * @param owner The address where will the transaction fee deduced
     * @param value The base for calculating the fee
     * @return True if the transfer was successful
     */
    function processTransactionFee(address owner, uint256 value) readyModule external returns (bool success) {
        /*
            Charge transaction fee. It can be called only by moduleHandler  
        
            @owner      From who.
            @value      Quantity to calculate the fee
            
            @success    Was the Function successful?
        */
        require( super.isModuleHandler(msg.sender) );
        var (_success, _fee) = getTransactionFee(value);
        _processTransactionFee(owner, _fee);
        return true;
    }
    function mint(address owner, uint256 value) readyModule external returns (bool success) {
        /*
            Generating tokens. It can be called only by ICO contract or the moduleHandler.
            
            @owner      Address
            @value      Amount.
            
            @success    Was the Function successful?
        */
        require( super.isModuleHandler(msg.sender) );
        _mint(owner, value);
        return true;
    }
    function burn(address owner, uint256 value) readyModule external returns (bool success) {
        /*
            Burning the token. Can call only modulehandler
            
            @owner     Burn the token from this address
            @value     Quantity
            
            @success    Was the Function successful?
        */
        require( super.isModuleHandler(msg.sender) );
        _burn(owner, value);
        return true;
    }
    /* Internals */
    function _transferToContract(address from, address to, uint256 amount, bytes extraData) internal {
        /*
            Internal function to start transactions to a contract
            
            @from           From who
            @to             To who
            @amount         Quantity
            @extraData      Extra data the receiver will get
        */
        _transfer(from, to, amount, true);
        require( checkContract(to) );
        var (_success, _back) = thirdPartyContract(to).receiveToken(from, amount, extraData);
        require( _success );
        require( amount > _back );
        if ( _back > 0 ) {
            _transfer(to, from, _back, false);
        }
    }
    function _transfer(address from, address to, uint256 amount, bool fee) internal {
        /*
            Internal function to start transactions. When Tokens are sent, transaction fee is charged
            During ICO transactions are allowed only from genesis addresses.
            After sending the tokens, the ModuleHandler is notified and it will broadcast the fact among members 
            
            The 0xa636a97578d26a3b76b060bbc18226d954cf3757 address are blacklisted.
            
            @from       From who
            @to         To who
            @amount     Quantity
            @fee        Deduct transaction fee - yes or no?
        */
        bool _success;
        uint256 _fee;
        uint256 _amount = amount;
        require( from != 0x00 && to != 0x00 && to != 0xa636a97578d26a3b76b060bbc18226d954cf3757 );
        if( fee ) {
            (_success, _fee) = getTransactionFee(amount);
            require( _success );
            if ( db.balanceOf(from) == amount ) {
                _amount = safeSub(amount, _fee);
            }
        }
        require( db.balanceOf(from) >= safeAdd(_amount, _fee) );
        require( db.decrease(from, _amount) );
        require( db.increase(to, _amount) );
        if ( fee && _fee > 0 ) { _processTransactionFee(from, _fee); }
        require( moduleHandler(moduleHandlerAddress).broadcastTransfer(from, to, _amount) );
    }
    function _processTransactionFee(address owner, uint256 feeAmount) internal {
        /*
            Internal function to charge the transaction fee. A certain quantity is burnt, the rest is sent to the Schelling game prize pool.
            No transaction fee during ICO.
            
            @owner      From who
            @value      Fee for subtract
        */
        uint256 _forBurn = safeMul(feeAmount, transactionFeeBurn) / 100;
        uint256 _forSchelling = safeSub(feeAmount, _forBurn);
        var (_success, _found, _schellingAddr) = moduleHandler(moduleHandlerAddress).getModuleAddressByName('Schelling');
        require( _success );
        if ( _found && _schellingAddr != 0x00) {
            require( db.decrease(owner, _forSchelling) );
            require( db.increase(_schellingAddr, _forSchelling) );
            _burn(owner, _forBurn);
            bytes memory _data;
            Transfer(owner, _schellingAddr, _forSchelling, _data);
            require( moduleHandler(moduleHandlerAddress).broadcastTransfer(owner, _schellingAddr, _forSchelling) );
        } else {
            _burn(owner, feeAmount);
        }
    }
    function _mint(address owner, uint256 value) internal {
        /*
            Internal function to generate tokens
            
            @owner     Token is credited to this address
            @value     Quantity
        */
        require( db.increase(owner, value) );
        require( moduleHandler(moduleHandlerAddress).broadcastTransfer(0x00, owner, value) );
        Mint(owner, value);
    }
    function _approve(address spender, uint256 amount, uint256 nonce) internal {
        /*
            Internal Function to authorise another address to use a certain quantity of the authorising owner’s balance.
            If the transaction count not match the authorise fails.
            
            @spender           Address of authorised party
            @amount            Token quantity
            @nonce             Transaction count
        */
        require( msg.sender != spender );
        var (_success, _remaining, _nonce) = db.getAllowance(msg.sender, spender);
        require( _success && ( _nonce == nonce ) );
        require( db.setAllowance(msg.sender, spender, amount, nonce) );
        Approval(msg.sender, spender, amount);
    }
    function _burn(address owner, uint256 value) internal {
        /*
            Internal function to burn the token
     
            @owner     Burn the token from this address
            @value     Quantity
        */
        require( db.decrease(owner, value) );
        require( moduleHandler(moduleHandlerAddress).broadcastTransfer(owner, 0x00, value) );
        Burn(owner, value);
    }
    function isContract(address addr) internal returns (bool success) {
        /*
            Internal function to check if the given address is natural, or a contract
            
            @addr       Address to be checked
            
            @success    Is the address crontact or not
        */
        uint256 _codeLength;
        assembly {
            _codeLength := extcodesize(addr)
        }
        return _codeLength > 0;
    }
    function checkContract(address addr) internal returns (bool appropriate) {
        return thirdPartyContract(addr).CORAddress() == address(this);
    }
    /* Constants */
    function allowance(address owner, address spender) constant returns (uint256 remaining, uint256 nonce) {
        /*
            Get the quantity of tokens given to be used
            
            @owner         Authorising address
            @spender       Authorised address
            
            @remaining     Tokens to be spent
            @nonce         Transaction count
        */
        var (_success, _remaining, _nonce) = db.getAllowance(owner, spender);
        require( _success );
        return (_remaining, _nonce);
    }
    function getTransactionFee(uint256 value) public constant returns (bool success, uint256 fee) {
        /*
            Transaction fee query.
            
            @value      Quantity to calculate the fee
            
            @success    Was the Function successful?
            @fee        Amount of Transaction fee
        */
        fee = safeMul(value, transactionFeeRate) / transactionFeeRateM / 100;
        if ( fee > transactionFeeMax ) { fee = transactionFeeMax; }
        else if ( fee < transactionFeeMin ) { fee = transactionFeeMin; }
        return (true, fee);
    }
    function balanceOf(address owner) constant returns (uint256 value) {
        /*
            Token balance query
            
            @owner      Address
            
            @value      Balance of address
        */
        return db.balanceOf(owner);
    }
    function totalSupply() constant returns (uint256 value) {
        /*
            Total token quantity query
            
            @value      Total token quantity
        */
        return db.totalSupply();
    }
    /* Events */
    event AllowanceUsed(address indexed spender, address indexed owner, uint256 indexed value);
    event Mint(address indexed addr, uint256 indexed value);
    event Burn(address indexed addr, uint256 indexed value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _value, bytes _extraData);
}

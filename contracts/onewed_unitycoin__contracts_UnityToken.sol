pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './IRefundHandler.sol';


contract UnityToken is StandardToken, Ownable {
    string public name = "";
    string public symbol = "";
    uint256 public constant decimals = 18;

    mapping (address => bool) internal allowedOverrideAddresses;

    bool public tokenActive = false;

    modifier onlyIfTokenActiveOrOverride() {
        // msg.sender or any addresses listed in the overrides
        // can perform token transfers while inactive
        require(tokenActive || msg.sender == owner || allowedOverrideAddresses[msg.sender]);
        _;
    }

    modifier onlyIfValidAddress(address _to) {
        // prevent 'invalid' addresses for transfer destinations
        require(_to != 0x0);
        // don't allow transferring to this contract's address
        require(_to != address(this));
        _;
    }

    event TokenActivated();

    function UnityToken(uint256 _totalSupply) public {
        totalSupply = _totalSupply;
        // msg.sender == owner of the contract
        balances[msg.sender] = totalSupply;
    }

    /// @dev Same ERC20 behavior, but reverts if not yet active.
    /// @param _spender address The address which will spend the funds.
    /// @param _value uint256 The amount of tokens to be spent.
    function approve(address _spender, uint256 _value) public onlyIfTokenActiveOrOverride onlyIfValidAddress(_spender) returns (bool) {
        return super.approve(_spender, _value);
    }

    /// @dev Same ERC20 behavior, but reverts if not yet active.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    function transfer(address _to, uint256 _value) public onlyIfTokenActiveOrOverride onlyIfValidAddress(_to) returns (bool) {
        return super.transfer(_to, _value);
    }

    function ownerSetOverride(address _address, bool enable) external onlyOwner {
        allowedOverrideAddresses[_address] = enable;
    }

    function ownerSetVisible(string _name, string _symbol) external onlyOwner {
        // no changes once the token is active
        require(!tokenActive);
        // only allow it to be set once
        require(bytes(symbol).length == 0);

        // By holding back on setting these, it prevents the token
        // from being a duplicate in ERC token searches if the need to
        // redeploy arises prior to the crowdsale starts.
        // Mainly useful during testnet deployment/testing.
        name = _name;
        symbol = _symbol;
    }

    function ownerActivateToken() external onlyOwner {
        require(!tokenActive);
        require(bytes(symbol).length > 0);

        tokenActive = true;
        TokenActivated();
    }

    function claimRefund(address _address) external {
        uint256 _balance = balances[msg.sender];

        // Positive token balance required to perform a refund
        require(_balance > 0);

        // this mitigates re-entrancy concerns
        balances[msg.sender] = 0;

        // Attempt to transfer wei back to msg.sender from the
        // crowdsale contract
        // Note: re-entrancy concerns are also addressed within
        // `handleRefundRequest`
        IRefundHandler refundHandler = IRefundHandler(_address);
        // this will throw an exception if any
        // problems or if refunding isn't enabled
        refundHandler.handleRefundRequest(msg.sender);

        // If we've gotten here, then the wei transfer above
        // worked (didn't throw an exception) and it confirmed
        // that `msg.sender` had an ether balance on the contract.
        // Now do token transfer from `msg.sender` back to
        // `owner` completes the refund.
        balances[owner] = balances[owner].add(_balance);
        Transfer(msg.sender, owner, _balance);
    }
}

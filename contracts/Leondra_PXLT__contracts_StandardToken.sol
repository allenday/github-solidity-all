pragma solidity ^0.4.15;

import "./SafeMath.sol";

/**
 * @title The abstract ERC-20 Token Standard definition.
 *
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract Token {
    /// @dev Returns the total token supply.
    uint256 public totalSupply;

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    /// @dev MUST trigger when tokens are transferred, including zero value transfers.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /// @dev MUST trigger on any successful call to approve(address _spender, uint256 _value).
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @title Default implementation of the ERC-20 Token Standard.
 */
contract StandardToken is Token {

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
        _;
    }

    /**
     * @dev Transfers _value amount of tokens to address _to, and MUST fire the Transfer event. 
     * @dev The function SHOULD throw if the _from account balance does not have enough tokens to spend.
     *
     * @dev A token contract which creates new tokens SHOULD trigger a Transfer event with the _from address set to 0x0 when tokens are created.
     *
     * Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
     *
     * @param _to The receiver of the tokens.
     * @param _value The amount of tokens to send.
     * @return True on success, false otherwise.
     */
    function transfer(address _to, uint256 _value)
    public
    returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
            balances[_to] = SafeMath.add(balances[_to], _value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.
     *
     * @dev The transferFrom method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf. 
     * @dev This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in 
     * @dev sub-currencies. The function SHOULD throw unless the _from account has deliberately authorized the sender of 
     * @dev the message via some mechanism.
     *
     * Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
     *
     * @param _from The sender of the tokens.
     * @param _to The receiver of the tokens.
     * @param _value The amount of tokens to send.
     * @return True on success, false otherwise.
     */
    function transferFrom(address _from, address _to, uint256 _value)
    public
    returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
            balances[_to] = SafeMath.add(balances[_to], _value);
            balances[_from] = SafeMath.sub(balances[_from], _value);
            allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns the account balance of another account with address _owner.
     *
     * @param _owner The address of the account to check.
     * @return The account balance.
     */
    function balanceOf(address _owner)
    public constant
    returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * @dev Allows _spender to withdraw from your account multiple times, up to the _value amount. 
     * @dev If this function is called again it overwrites the current allowance with _value.
     *
     * @dev NOTE: To prevent attack vectors like the one described in [1] and discussed in [2], clients 
     * @dev SHOULD make sure to create user interfaces in such a way that they set the allowance first 
     * @dev to 0 before setting it to another value for the same spender. THOUGH The contract itself 
     * @dev shouldn't enforce it, to allow backwards compatilibilty with contracts deployed before.
     * @dev [1] https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/
     * @dev [2] https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     * @return True on success, false otherwise.
     */
    function approve(address _spender, uint256 _value)
    public
    onlyPayloadSize(2)
    returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Returns the amount which _spender is still allowed to withdraw from _owner.
     *
     * @param _owner The address of the sender.
     * @param _spender The address of the receiver.
     * @return The allowed withdrawal amount.
     */
    function allowance(address _owner, address _spender)
    public constant
    onlyPayloadSize(2)
    returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

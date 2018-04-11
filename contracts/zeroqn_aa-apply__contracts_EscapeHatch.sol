pragma solidity ^0.4.17;

/**
 * @title EscapeHatch
 * @dev Monthly salaries will be sent to this contract firstly, then wait
 * for one day before employees can actually withdraw their salaires. Owner
 * can pause this contract either directly or through Payment contract at
 * anytime, then owner can withdraw salaries from this contract.
 */

import "./SharedLibrary.sol";

import "zeppelin-solidity/contracts/token/ERC20.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


contract EscapeHatch is Pausable {

    using SafeMath for uint;

    address public payment;
    address[] public tokens;

    mapping (address => uint256) public ethBalances;
    // token address => employee account address => balance
    mapping (address => mapping (address => uint256)) tBalances;
    // token address => bool
    mapping (address => bool) isTokenListed;
    mapping (address => uint256) public endQuaratineDates;

    modifier onlyPaymentOrOwner() {
        require(msg.sender == owner || msg.sender == payment);
        _;
    }

    modifier afterQuaratine() {
        require(now > endQuaratineDates[msg.sender]);
        _;
    }

    event OnQuarantineEth(address employee, uint256 indexed amount);
    event OnQuarantineToken(
        address employee,
        address token,
        uint256 indexed amount
    );
    event OnWithdraw(address employee);
    event OnEmergencyWithdraw();

    function EscapeHatch()
        public
    {
        // constructor
    }

    function setPayment(address _payment)
        onlyOwner
        external
    {
        require(_payment != 0x0);

        payment = _payment;
    }

    function pausePayment()
        onlyPaymentOrOwner
        external
    {
        paused = true;
        Pause();
    }

    // @dev Quarantine given amount of eth and tokens for one day for specified
    // employee account address
    // @param _tokens address[] array of token addresses
    // @param _amounts uint256[] array of token amount
    function quarantine(
        address employee,
        address[] _tokens,
        uint256[] _amounts
    )
        whenNotPaused
        onlyPaymentOrOwner
        payable
        external
    {
        require(_tokens.length == _amounts.length);

        if (msg.value > 0) {
            ethBalances[employee] = ethBalances[employee].add(msg.value);
            OnQuarantineEth(employee, msg.value);
        }

        for (uint i = 0; i < _tokens.length; i++) {
            if (_tokens[i] == 0x0 || _amounts[i] == 0) {
                continue;
            }
            if (!isTokenListed[_tokens[i]]) {
                tokens.push(_tokens[i]);
                isTokenListed[_tokens[i]] = true;
            }

            uint256 oldTAmount = tBalances[_tokens[i]][employee];
            tBalances[_tokens[i]][employee] = oldTAmount.add(_amounts[i]);
            OnQuarantineToken(employee, _tokens[i], _amounts[i]);
        }

        endQuaratineDates[employee] = now + 1 days;
    }

    function withdraw()
        whenNotPaused
        afterQuaratine
        external
    {
        if (ethBalances[msg.sender] > 0) {
            uint256 amount = ethBalances[msg.sender];
            ethBalances[msg.sender] = 0;

            msg.sender.transfer(amount);
        }

        for (uint i = 0; i < tokens.length; i++) {
            uint256 tAmount = tBalances[tokens[i]][msg.sender];
            tBalances[tokens[i]][msg.sender] = 0;

            ERC20(tokens[i]).transfer(msg.sender, tAmount);
        }

        OnWithdraw(msg.sender);
    }

    function emergencyWithdraw()
        onlyOwner
        whenPaused
        external
    {
        SharedLibrary.withdrawFrom(this, msg.sender, tokens);
        OnEmergencyWithdraw();
    }

}

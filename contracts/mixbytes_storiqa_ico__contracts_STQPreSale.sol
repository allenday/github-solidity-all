pragma solidity 0.4.15;

import './STQToken.sol';
import 'zeppelin-solidity/contracts/ReentrancyGuard.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


/// @title Storiqa pre-sale contract
contract STQPreSale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function STQPreSale(address token, address funds) {
        require(address(0) != address(token) && address(0) != address(funds));

        m_token = STQToken(token);
        m_funds = funds;
    }


    // PUBLIC interface: payments

    // fallback function as a shortcut
    function() payable {
        require(0 == msg.data.length);
        buy();  // only internal call here!
    }

    /// @notice ICO participation
    /// @return number of STQ tokens bought (with all decimal symbols)
    function buy()
        public
        payable
        nonReentrant
        returns (uint)
    {
        address investor = msg.sender;
        uint256 payment = msg.value;
        require(payment >= c_MinInvestment);
        require(now < 1507766400);

        // issue tokens
        uint stq = payment.mul(c_STQperETH);
        m_token.mint(investor, stq);

        // record payment
        m_funds.transfer(payment);
        FundTransfer(investor, payment, true);

        return stq;
    }

    /// @notice Tests ownership of the current caller.
    /// @return true if it's an owner
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to
    // addOwner/changeOwner and to isOwner.
    function amIOwner() external constant onlyOwner returns (bool) {
        return true;
    }


    // FIELDS

    /// @notice starting exchange rate of STQ
    uint public constant c_STQperETH = 150000;

    /// @notice minimum investment
    uint public constant c_MinInvestment = 10 finney;

    /// @dev contract responsible for token accounting
    STQToken public m_token;

    /// @dev address responsible for investments accounting
    address public m_funds;
}

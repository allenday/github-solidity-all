pragma solidity ^0.4.10;
import './SafeMath.sol';


contract TokenSyndicate {
    uint256 public constant kwei = 1000;

    address public tokenContract;
    uint256 public tokenExchangeRate;
    uint256 public bountyPerKwei;
    uint256 public maxPresaleWeiAllowed;
    uint256 public refundStartBlock;
    address public winner;

    uint256 public totalPresale;
    uint256 public totalBounties;

    mapping(address => uint256) public presaleBalances;
    mapping(address => uint256) public bountyBalances;

    event LogInvest(address indexed _to, uint256 bounty, uint256 presale);
    event LogDonate(address indexed _to, uint256 donation);
    event LogRefund(address indexed _to, uint256 bounty, uint256 presale);
    event LogWithdrawTokens(address indexed _to, uint256 tokens);
    event LogWithdrawBounty(address indexed _to, uint256 bounty);

    modifier onlyWithoutWinner() { assert(winner == address(0));  _; }
    modifier onlyWithWinner() { assert(winner != address(0)); _; }
    modifier whenRefundIsPermitted() { assert(block.number >= refundStartBlock); _; }

    function TokenSyndicate(
    address _tokenContract,
    uint256 _tokenExchangeRate,
    uint256 _bountyPerKwei,
    uint256 _maxPresaleWeiAllowed,
    uint256 _refundStartBlock) {
        assert(_bountyPerKwei < kwei);       // do not allow a bounty of 100%.
        assert(_bountyPerKwei > 0);          // do not allow a bounty of zero.
        assert(_maxPresaleWeiAllowed > 0);      // the eth allowed must be greater than zero.
        assert(_tokenContract != address(0));   // the token contract may not be at the zero address.
        assert(_tokenExchangeRate > 0);         // the token exchange rate must not be zero.

        tokenContract = _tokenContract;
        tokenExchangeRate = _tokenExchangeRate;
        bountyPerKwei = _bountyPerKwei;
        maxPresaleWeiAllowed = _maxPresaleWeiAllowed;
        refundStartBlock = _refundStartBlock;

        totalPresale = 0;
        totalBounties = 0;
        winner = address(0);
    }

    /*
       Attempt to purchase the tokens from the token contract.
       Whichever address manages to successfully purchase/create the tokens will be the 'winner'.
       The 'winner' is allowed to withdraw the bounties from this contract.
    */
    function buyTokens() external onlyWithoutWinner {
        winner = msg.sender;
        assert(tokenContract.call.value(totalPresale)(bytes4(sha3("createTokens()"))));
    }

    /*
        Invest in this contract in order to have tokens purchased on your behalf when the buyTokens() contract
        is called without a `throw`.
    */
    function invest() payable external {
        assert(msg.value > 0);
        assert(msg.value >= kwei);  // this is a naive (but cheap) method of ensuring the bounty is always >= 1

        /*
            As the EVM does not currently support decimals, we are multiplying both msg.value and the bounty
            by 1000 before calculating the bounty ratio in order to gain a reasonable degree of precision.
        */
        uint256 msg_value_with_precision = SafeMath.mul(msg.value, kwei);
        uint256 bounty_with_precision = SafeMath.mul(bountyPerKwei, SafeMath.div(msg_value_with_precision, kwei));
        uint256 final_bounty = SafeMath.div(bounty_with_precision, kwei);
        uint256 final_presale = SafeMath.sub(msg.value, final_bounty);

        bountyBalances[msg.sender] = SafeMath.add(bountyBalances[msg.sender], final_bounty);
        presaleBalances[msg.sender] = SafeMath.add(presaleBalances[msg.sender], final_presale);
        totalBounties = SafeMath.add(totalBounties, final_bounty);
        totalPresale = SafeMath.add(totalPresale, final_presale);
        assert(totalPresale <= maxPresaleWeiAllowed);
        LogInvest(msg.sender, final_bounty, final_presale);       // create an event
    }

    /*
        Contribute to the bounty.
        This will not result in the purchase of more tokens, it will simply increase the bounty.
    */
    function donate() payable external onlyWithoutWinner {
        assert(msg.value > 0);
        bountyBalances[msg.sender] = SafeMath.add(bountyBalances[msg.sender], msg.value);
        totalBounties = SafeMath.add(totalBounties, msg.value);
        LogDonate(msg.sender, msg.value);
    }

    /*
        Get the presaleBalance (ETH) and bountyBalance (ETH) for an address.
    */
    function balanceOf(address _owner) constant returns (uint256 presaleBalance, uint256 bountyBalance) {
        return (presaleBalances[_owner], bountyBalances[_owner]);
    }

    /*
        Transfer an accounts token entitlement to itself.
        This can only be called if there has been a 'winner'.
    */

    function withdrawTokens() onlyWithWinner {
        uint256 tokens = SafeMath.mul(presaleBalances[msg.sender], tokenExchangeRate);
        assert(tokens > 0);

        totalPresale = SafeMath.sub(totalPresale, presaleBalances[msg.sender]);
        presaleBalances[msg.sender] = 0;

        /*
           Attempt to transfer tokens to msg.sender.
           Note: we are relying on the token contract to return a success bool (true for success). If this
           bool is not implemented as expected it may be possible for an account to withdraw more tokens than
           it is entitled to.
        */
        assert(tokenContract.call(bytes4(sha3('transfer(address,uint256)')), msg.sender, tokens));
        LogWithdrawTokens(msg.sender, tokens);
    }

    /*
        Collect the bounty for successfully executing the token purchase.
    */
    function withdrawBounty() external onlyWithWinner {
        assert(msg.sender == winner);
        assert(totalBounties > 0);

        uint256 entitlement = totalBounties;
        totalBounties = 0;

        msg.sender.transfer(entitlement);
        LogWithdrawBounty(msg.sender, entitlement);
    }

    /*
        Refund an accounts investment and bounty.
        This is only possible if there has not been a 'winner' (ie, if tokens have not been purchased).
    */
    function refund() external whenRefundIsPermitted onlyWithoutWinner {
        uint256 bountyValue = bountyBalances[msg.sender];
        uint256 presaleValue = presaleBalances[msg.sender];
        uint256 totalValue = SafeMath.add(bountyValue, presaleValue);

        assert(totalValue > 0);

        bountyBalances[msg.sender] = 0;
        presaleBalances[msg.sender] = 0;
        totalBounties = SafeMath.sub(totalBounties, bountyValue);
        totalPresale = SafeMath.sub(totalPresale, presaleValue);
        msg.sender.transfer(totalValue);
        LogRefund(msg.sender, bountyValue, presaleValue);
    }
}




pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import './UnityToken.sol';
import './IRefundHandler.sol';


contract UnitySale is Ownable, Pausable, IRefundHandler {
    using SafeMath for uint256;

    // this sale contract is creating the UnityToken
    // contract, and so will own it
    UnityToken internal token;

    // UNIX timestamp (UTC) based start and end, inclusive
    uint256 public start;
    uint256 public end;

    bool public isPresale;
    bool public isRefunding = false;

    uint16 internal constant tokenToWeiMultiplier = 10000;

    uint256 public minFundingGoalWei;
    uint256 public minContributionWei;
    uint256 public maxContributionWei;

    uint256 public weiRaised;
    uint256 internal weiForRefund;

    mapping (address => uint256) public contributions;

    struct DiscountTranche {
        // this will be a timestamp that is calculated based on
        // the # of hours a tranche rate is to be active for
        uint256 end;
        // should be a % number between 0 and 100
        uint8 discount;
    }
    DiscountTranche[] internal discountTranches;
    uint8 internal currentDiscountTrancheIndex = 0;

    event ContributionReceived(address indexed buyer, bool indexed presale, uint8 indexed rate, uint256 value, uint256 tokens);
    event RefundsEnabled();
    event Refunded(address indexed buyer, uint256 weiAmount);
    event ToppedUp();

    function UnitySale(
        address _token,
        bool _isPresale,
        uint256 _minFundingGoalWei,
        uint256 _minContributionWei,
        uint256 _maxContributionWei,
        uint256 _start,
        uint256 _durationHours,
        uint256[] _hourBasedDiscounts
    ) public {
        require(_token != 0x0);
        // either have NO max contribution or the max must be more than the min
        require(_maxContributionWei == 0 || _maxContributionWei > _minContributionWei);
        // sale must have a duration!
        require(_durationHours > 0);

        token = UnityToken(_token);

        isPresale = _isPresale;

        start = _start;
        end = start.add(_durationHours.mul(1 hours));

        minFundingGoalWei = _minFundingGoalWei;
        minContributionWei = _minContributionWei;
        maxContributionWei = _maxContributionWei;

        // this will throw if the # of hours and
        // discount % don't come in pairs
        uint256 _end = start;
        for (uint i = 0; i < _hourBasedDiscounts.length; i += 2) {
            // calculate the timestamp where the discount rate will end
            _end = _end.add(_hourBasedDiscounts[i].mul(1 hours));

            // the calculated tranche end cannot go past the crowdsale end
            require(_end <= end);

            discountTranches.push(DiscountTranche(_end, uint8(_hourBasedDiscounts[i + 1])));
        }
    }

    function determineDiscountRate() internal returns (uint8) {
        uint8 rate = 0;

        if (currentDiscountTrancheIndex < discountTranches.length) {
            DiscountTranche storage d = discountTranches[currentDiscountTrancheIndex];
            if (d.end < now) {
                // find the next applicable tranche
                while (++currentDiscountTrancheIndex < discountTranches.length) {
                    d = discountTranches[currentDiscountTrancheIndex];

                    // this should always true on the first iteration of the
                    // while loop; it would have to be a ghost town of a
                    // crowdsale to jump past a tranche level (ie. multiple
                    // loop iterations here)
                    if (d.end > now)
                        break;
                }
            }

            // if the index is still valid, then we must have
            // a valid tranche, so return discount rate
            if (currentDiscountTrancheIndex < discountTranches.length)
                rate = d.discount;
        }

        return rate;
    }

    function () public payable whenNotPaused {
        require(!isRefunding);
        require(msg.sender != 0x0);
        require(msg.value >= minContributionWei);
        require(start <= now && end >= now);

        // prevent anything more than maxContributionWei per
        // contributor address
        uint256 weiContributionAllowed = maxContributionWei.sub(contributions[msg.sender]);
        require(weiContributionAllowed > 0);

        // are limited by the number of tokens remaining
        uint256 tokensRemaining = token.balanceOf(address(this));
        require(tokensRemaining > 0);

        // limit contribution's value based on max/previous contributions
        uint256 weiContribution = msg.value;
        if (weiContribution > weiContributionAllowed)
            weiContribution = weiContributionAllowed;

        // calculate token amount to be created
        uint256 tokens = weiContribution.mul(tokenToWeiMultiplier);
        uint8 rate = determineDiscountRate();
        if (rate > 0)
            tokens = tokens.mul(SafeMath.add(rate, 100)).div(100);

        if (tokens > tokensRemaining) {
            // there aren't enough tokens to fill the contribution amount,
            // so recalculate the contribution amount
            tokens = tokensRemaining;
            if (rate > 0)
                weiContribution = tokens.mul(100).div(SafeMath.mul(tokenToWeiMultiplier, SafeMath.add(rate, 100)));
            else
                weiContribution = tokens.div(tokenToWeiMultiplier);
        }

        // add the contributed wei to any existing value for the sender
        contributions[msg.sender] = contributions[msg.sender].add(weiContribution);
        ContributionReceived(msg.sender, isPresale, rate, weiContribution, tokens);

        require(token.transfer(msg.sender, tokens));

        weiRaised = weiRaised.add(weiContribution);

        uint256 _weiRefund = msg.value.sub(weiContribution);
        if (_weiRefund > 0)
            require(msg.sender.call.value(_weiRefund)());
    }

    // in case we need to return funds to this contract
    function ownerTopUp() external payable {}

    function ownerEnableRefunds() external onlyOwner {
        // a little protection against human error;
        // sale must be ended OR it must be paused
        require(paused || now > end);
        require(!isRefunding);

        weiForRefund = this.balance;
        isRefunding = true;
        RefundsEnabled();
    }

    function ownerTransferWei(address _beneficiary, uint256 _value) external onlyOwner {
        require(_beneficiary != 0x0);
        require(_beneficiary != address(token));
        // we cannot withdraw if we didn't reach the minimum funding goal
        require(minFundingGoalWei == 0 || weiRaised >= minFundingGoalWei);

        // if zero requested, send the entire amount, otherwise the amount requested
        uint256 amount = _value > 0 ? _value : this.balance;

        require(_beneficiary.call.value(amount)());
    }

    function ownerRecoverTokens(address _beneficiary) external onlyOwner {
        require(_beneficiary != 0x0);
        require(_beneficiary != address(token));
        require(now > end);

        uint256 tokensRemaining = token.balanceOf(address(this));
        if (tokensRemaining > 0)
            token.transfer(_beneficiary, tokensRemaining);
    }

    function handleRefundRequest(address _contributor) external {
        // Note that this method can only ever called by
        // the token contract's `claimRefund()` method;
        // everything that happens in here will only
        // succeed if `claimRefund()` works as well.

        require(isRefunding);
        // this can only be called by the token contract;
        // it is the entry point for the refund flow
        require(msg.sender == address(token));

        uint256 _wei = contributions[_contributor];

        // if this is zero, then `_contributor` didn't
        // contribute or they've already been refunded
        require(_wei > 0);

        // prorata the amount if necessary
        if (weiRaised > weiForRefund) {
            uint256 _n  = weiForRefund.mul(_wei).div(weiRaised);
            require(_n < _wei);
            _wei = _n;
        }

        // zero out their contribution, so they cannot
        // claim another refund; it's important (for
        // avoiding re-entrancy attacks) that this zeroing
        // happens before the transfer below
        contributions[_contributor] = 0;

        // give them their ether back; throws on failure
        require(_contributor.call.value(_wei)());

        Refunded(_contributor, _wei);
    }
}

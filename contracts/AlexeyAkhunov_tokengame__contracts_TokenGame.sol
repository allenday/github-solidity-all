pragma solidity ^0.4.10;

contract Token {
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Send tokens */
    function transfer(address _to, uint256 _value) {
        require(balanceOf[msg.sender] >= _value);            // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]);  // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* A contract attempts to get the tokens */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(balanceOf[_from] >= _value);                 // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]);  // Check for overflows
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    address public minter;

    function Token() {
        minter = msg.sender;
    }

    /* Allows the owner to mint more tokens */
    function mint(address _to, uint256 _value) returns (bool) {
        require(msg.sender == minter);                       // Only the minter is allowed to mint
        require(balanceOf[_to] + _value >= balanceOf[_to]);  // Check for overflows
        balanceOf[_to] += _value;
        totalSupply += _value;
        return true;
    }
}

// Withdraw contracts with 1 token giving entitlement to 1 wei
contract ExcessWithdraw {
    Token public token;
    uint public release_time;

    function ExcessWithdraw(uint _release_time, Token _token) {
        release_time = _release_time;
        token = _token;
    }

    function () payable {}

    function withdraw() {
        require(now >= release_time);
        require(token.balanceOf(msg.sender) > 0);
        uint amount = token.balanceOf(msg.sender);
        require(token.transferFrom(msg.sender, this, amount));
        msg.sender.transfer(amount);
    }
}

contract TokenDistribution {
    address public owner;
    uint256 public target_in_wei;                                 /* Minimum amount to collect - otherwise return everything */
    uint256 public cap_in_wei;                                    /* Maximum amount to accept - return the rest */
    uint256 public tokens_to_mint;                                /* How many tokens need to be issued */
    uint256 constant INITIAL_DURATION = 1 weeks;
    uint256 constant TIME_EXTENSION_FROM_DOUBLING = 2 days;
    uint256 constant TIME_OF_HALF_DECAY = 6 hours;
    uint256 constant MAX_LOCK_WEEKS = 100;                        /* Maximum number of weeks that the excess contribution can be locked for */
    uint256 constant FIXED_POINT_ONE = 1000000000000;             /* Equivalent of number "1" for fixed point arithmetics */
    uint256 constant FIXED_POINT_PRC = 1070000000000;             /* Equivalent of number "1.07" for fixed point arithmetics */
    Token public token;                                           /* Token contract where sold tokens are minted */
    uint256 public end_time;                                      /* Current end time */
    uint256 last_time = 0;                                        /* Timestamp of the latest contribution */
    uint256 public ema = 0;                                       /* Current value of the Exponential Moving Average */
    uint256 public ema_divisor = 0;                               /* Amount of wei given, including what has escaped */
    uint256 public total_wei_given = 0;                           /* Total amount of wei given via contribute function, minus escapes */
    uint256 public total_wei_accepted = 0;                        /* Total amount of wei accepted */
    mapping (uint256 => Token) public excess_tokens;              /* Excess tokens organised by lock weeks */
    mapping (uint256 => ExcessWithdraw) public excess_withdraws;  /* Excess withdraw contracts organised by lock weeks */
    mapping (uint256 => uint256) public wei_given_to_bucket;      /* Amount of wei given to specific bucket (lock_weeks is key in the mapping) */
    mapping (uint256 => uint256) public wei_accepted_from_bucket; /* Amount of wei accepted from specific bucket (lock_weeks is the key in the mapping) */
    mapping (address => mapping (uint256 => uint256)) public contributions; /* Contributions of a participant (first key) to a bucket (second key) */
    uint256 public last_bucket_closed = MAX_LOCK_WEEKS + 1;       /* Counter (goes from max_lock_weeks to 0) used to finalise bucket by bucket */
    bool public closing = false;                                  /* Set to true when at least one bucket is closed */
    bool public closed = false;                                   /* Set to true when the last bucket is closed */
    uint256 public cap_remainder;                                 /* As the buckets are getting closed, the cap_remainder reduced to what is left to allocate */

    // sqrt(2), sqrt(sqrt(2)), sqrt(sqrt(sqrt(2))), ...
    uint256[] FIXED_POINT_DECAYS =
        [1414213562370, 1189207115000, 1090507732670, 1044273782430, 1021897148650, 1010889286050, 1005429901110, 1002711275050, 1002711275050, 1000677130690,
         1000338508050, 1000169239710, 1000084616270, 1000042307240, 1000021153400, 1000010576640, 1000005288310, 1000002644150, 1000001322070, 1000000661040];

    function TokenDistribution(uint256 _target_in_wei, uint256 _cap_in_wei, uint256 _tokens_to_mint) {
        owner = msg.sender;
        target_in_wei = _target_in_wei;
        cap_in_wei = _cap_in_wei;
        cap_remainder = _cap_in_wei;
        tokens_to_mint = _tokens_to_mint;
        token = new Token();
        end_time = now + INITIAL_DURATION;
    }

    function exponential_decay(uint256 value, uint256 time) private returns (uint256 decayed) {
        if (time == 0) {
            return value;
        }
        // First, we halve the value for each unit of TIME_OF_HALF_DECAY
        uint256 shifts = time / TIME_OF_HALF_DECAY;
        if (shifts >= 256) {
            // Since uint is 256 bit, shifting more than 256 would produce zero
            return 0;
        }
        uint256 v = value >> shifts;
        uint256 t = time % TIME_OF_HALF_DECAY;
        uint256 decay = TIME_OF_HALF_DECAY; // This is half of the time of half decay
        for(uint8 i = 0; (i<20) && (decay > 0) && (v > 0); ++i) {
            decay >>= 1;
            if (t >= decay) {
                v = v * FIXED_POINT_ONE / FIXED_POINT_DECAYS[i];
                t -= decay;
            }
        }
        return v;
    }

    function contribute(uint256 lock_weeks) payable {
        require(now <= end_time);   // Check that the sale has not ended
        require(msg.value > 0);     // Check that something has been sent
        require(lock_weeks <= MAX_LOCK_WEEKS);
        contributions[msg.sender][lock_weeks] += msg.value;
        wei_given_to_bucket[lock_weeks] += msg.value;
        total_wei_given += msg.value;

        // Do not apply extension of the end_time if we are refilling the gap left by escapes
        if (total_wei_given <= ema_divisor) return;

        // Time weighted exponential moving average is computed over the size of the contributions
        ema = msg.value + exponential_decay(ema, now - last_time);
        last_time = now;
        ema_divisor = total_wei_given;
        uint256 extension = ema * TIME_EXTENSION_FROM_DOUBLING / ema_divisor;
        if (extension > TIME_EXTENSION_FROM_DOUBLING) {
            extension = TIME_EXTENSION_FROM_DOUBLING;
        }
        uint256 extended_time = now + extension;
        if (extended_time > end_time) {
            end_time = extended_time;
        }
    }

    function escape(uint256 bucket) {
        require(!closing);   // Check that no buckets are yet closed
        uint256 contribution = contributions[msg.sender][bucket];
        require(contribution > 0);
        contributions[msg.sender][bucket] = 0;
        wei_given_to_bucket[bucket] -= contribution;
        total_wei_given -= contribution;
        msg.sender.transfer(contribution);
    }

    function close_next_bucket() {
        require(now > end_time);                   /* Can only close buckets after the end of sale */
        require(!closed);                          /* Not all buckets closed yet */
        require(total_wei_given >= target_in_wei); /* Target must be reached */
        closing = true;
        uint256 bucket = last_bucket_closed - 1;
        while (bucket > 0 && wei_given_to_bucket[bucket] == 0) {
            bucket--;
        }
        uint256 bucket_contribution = wei_given_to_bucket[bucket];
        if (bucket_contribution > 0) {
            // Current bucket will get the biggest contritubion multiplier (due to highest lock time)
            // The muliplier decays by 1.07 as the lock time decreased by a week
            uint256 contribution_multiplier = FIXED_POINT_ONE;
            uint256 contribution_sum = bucket_contribution;
            uint256 b = bucket;
            while (b > 0) {
                b--;
                contribution_multiplier = contribution_multiplier * FIXED_POINT_ONE / FIXED_POINT_PRC;
                contribution_sum += wei_given_to_bucket[b] * contribution_multiplier / FIXED_POINT_ONE;
            }
            // Compute accepted contribution for this bucket
            uint256 accepted = cap_remainder * wei_given_to_bucket[bucket] / contribution_sum;
            if (accepted > bucket_contribution) {
                accepted = bucket_contribution;
            }
            wei_accepted_from_bucket[bucket] = accepted;
            total_wei_accepted += accepted;
            cap_remainder -= accepted;
            if (accepted < bucket_contribution) {
                // Only call if there is an excess
                move_excess_for_bucket(bucket, bucket_contribution - accepted);
            }
            last_bucket_closed = bucket;
        }
        if (bucket == 0) {
            closed = true;
        }
    }

    function move_excess_for_bucket(uint256 bucket, uint256 excess) private {
        Token token_contract = new Token();
        excess_tokens[bucket] = token_contract;
        ExcessWithdraw withdraw_contract = new ExcessWithdraw(end_time + bucket * (1 weeks), token_contract);
        excess_withdraws[bucket] = withdraw_contract;
        withdraw_contract.transfer(excess);
    }

    // Claim tokens for players and send ether to the owner
    function claim_tokens(address player, uint256 bucket) {
        require(closed); /* Claims only allowed when all buckets are closed */
        uint256 contribution = contributions[player][bucket];
        require(contribution > 0);
        contributions[player][bucket] = 0;
        uint256 wei_accepted = contribution * wei_accepted_from_bucket[bucket] / wei_given_to_bucket[bucket];
        uint256 tokens = wei_accepted * tokens_to_mint / total_wei_accepted;
        require(tokens == 0 || token.mint(player, tokens));
        Token excess_token = excess_tokens[bucket];
        uint256 excess = contribution - wei_accepted;
        require(excess == 0 || excess_token.mint(player, excess));
        require(wei_accepted == 0 || owner.send(wei_accepted));
    }
}

contract PrizePot {
    TokenDistribution public dist;

    function PrizePot(TokenDistribution _dist) {
        dist = _dist;
    }

    function() payable {}

    function claim_prize() {
        Token token = dist.token();
        uint256 token_amount = token.balanceOf(msg.sender);
        uint256 wei_amount = this.balance * token_amount / (dist.tokens_to_mint() - token.balanceOf(this));
        require(token.transferFrom(msg.sender, this, token_amount));
        msg.sender.transfer(wei_amount);
    }

    function cancel() {
        require(now > dist.end_time());
        require(dist.total_wei_given() < dist.target_in_wei());
        dist.owner().transfer(this.balance);
    } 
}

contract TokenGame is TokenDistribution {

    PrizePot public prize_pot;

    function TokenGame() TokenDistribution(1000000 /* target */, 1000000000 /* cap */, 1000000000 /* tokens to mint */) {
        prize_pot = new PrizePot(this);
    }
}

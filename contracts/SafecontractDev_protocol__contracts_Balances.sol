pragma solidity ^0.4.15;
import './AO.sol';
import './Backdoor.sol';            // temporary
import './SafeMath.sol';

import './interfaces/IBalances.sol';

/**
    The idea of this contract is that it will hold the business
    logic of user funds held in a Safe denominated in ether. 
    (Eventually supported ERC20 tokens as well.) We do this in
    order to isolate user funds from the higher level interface
    of the Safe in case we need to upgrade the Safe contract in
    the future we can do so with minimal impact (ideally, no impact)
    on the user.

 */
contract Balances is Backdoor, IBalances {
    using SafeMath for uint;

    uint MULTIPLIER = 1.0;              // The bonus for having AO deposits.

    AO safeToken;                       // Address of the official SafeToken
    IRewardDAO rewardDAO;               // The RewardDAO addresss.
    address user;

    event Deposit(uint indexed amount); // event released when deposit to safe successful

    /**
        @dev constructor

        @param _rewardDAO The RewardDAO address.
        @param _safeToken The SafeToken address.
        @param _user      The user address, whose balances these are.
    */
    function Balances(address _rewardDAO,
                      address _safeToken,
                      address _user) {
        rewardDAO = IRewardDAO(_rewardDAO);
        safeToken = AO(_safeToken);                    
        user = _user;
    }

    modifier onlyRewardDAO() {
        assert(msg.sender == address(rewardDAO));
        _;
    }

    /**
        @dev Deposits said token into the balance.
             Must be called from the known RewardDAO contract.

         @param _user     Address of the user whose safe deposit is being added to
         @param _token    Address of the ERC20 token being deposited, or the ether wrapper
         @param _amount   Amount of said token being deposited into safe
    */
    function deposit(address _user, address _token, uint _amount)
        onlyRewardDAO
    {
        // TODO: Decide if it's necessary to have the RewardDAO call
        //       this function to deposit tokens into the balances 
        //       contract. Or, can we keep the current implementation
        //       and just transferFrom the RewardDAO? I think it would
        //       be smarter to have users only approve their own balances
        //       instead of the RewardDAO in the case of hacks, only the 
        //       unclaimed AO would be at risk. 

        require(isContract(rewardDAO));
        require(msg.sender == address(rewardDAO));

        IERC20Token token = IERC20Token(_token);
        token.transferFrom(_user, address(this), _amount);
        assert(rewardDAO.onDeposit(_amount));
        Deposit(msg.value);
    }

    function withdraw(address _user) 
        onlyRewardDAO
    {
        // TODO: Similar concerns as above. I believe this would be the right
        //       way to go about it but it needs more thought behind it. We could 
        //       do the verification checks in the RewardDAO function that calls this
        //       one. And then in here do something like:
        assert(_user == user);
        // TODO: Right now it would be most straight forward to do a complete
        //       withdrawal, but we should keep thinking about ways to eventually
        //       implement incrementally withdrawals. Anyway, I digress the main point
        //       is that we might need to store the tokens in RewardDAO and the balances,
        //       and then verify that the address array store of both RewardDAO and Balances
        //       is the same... Maybe we should extract out another contract for this,
        //       something like "VerifiedTokens.sol" or "SupportedTokens.sol" so that
        //       we can share this information across the two contracts as well as shortening
        //       the current implementation of RewardDAO.
    }

    /**
        @dev Returns the balance (in AO) associated with the Balance account associated with
             the account specified

        @param _account                    Account for which Balance amount to be read
    */
    function queryBalance(address _account)
        public constant returns (uint)
    {
        return safeToken.balanceOf(_account).mul(MULTIPLIER);
    }

    /** ----------------------------------------------------------------------------
        *                       Private helper functions                             *
        ---------------------------------------------------------------------------- */

    /**
        @dev determines whether or not the address pointed to corresponds to a valid contract address

        @param  _addr             Address being investigated
        @return boolean of whether or not we are looking at valid contract
    */
    function isContract(address _addr) 
        constant internal returns(bool)
    {
        uint size;
        if (_addr == 0) {
            return false;
        }
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    /**
        @dev sets a new official address of the AO

        @param  _newSafeToken     New address associated with the rewardsDAO
    */
    function setSafeToken(address _newSafeToken) {
        require(safeToken != _newSafeToken);
        assert(_newSafeToken != 0x0);

        delete safeToken;
        safeToken = AO(_newSafeToken);
    }
}
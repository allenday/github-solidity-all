pragma solidity ^0.4.17;

import "./StandardToken.sol";

/**
 * @title The Pre-Leo Token contract.
 *
 * Credit: Taking ideas from BAT token and NET token
 */
contract PXLToken is StandardToken {

    // Token metadata
    string public constant name = "Pre-Leo Token";
    string public constant symbol = "PXLT";
    uint256 public constant decimals = 18;
    string public constant version = "0.9";

    // Fundraising parameters
    enum ContractState { Fundraising, Finalized, Redeeming, Paused }
    ContractState public state;           // Current state of the contract
    ContractState private savedState;     // State of the contract before pause

    uint256 public fundingStartBlock;        // These two blocks need to be chosen to comply with the
    uint256 public fundingEndBlock;          // start date and 28 day duration requirements
    uint256 public exchangeRateChangesBlock; // block number that triggers the exchange rate change

    address public admin1; // First administrator for multi-sig mechanism
    address public admin2; // Second administrator for multi-sig mechanism

    uint256 public constant TOKEN_FIRST_EXCHANGE_RATE = 200; // 200 PXLTs per 1 ETH
    uint256 public constant TOKEN_SECOND_EXCHANGE_RATE = 175; // 175 PXLTs per 1 ETH
    uint256 public constant TOKEN_CREATION_CAP = 10 * (10**6) * 10**decimals; // 10 million PXLTs
    uint256 public constant ETH_RECEIVED_CAP = 50 * (10**3) * 10**decimals; // 50 000 ETH
    uint256 public constant ETH_RECEIVED_MIN = 10 * (10**3) * 10**decimals; // 10 000 ETH
    uint256 public constant TOKEN_MIN = 1 * 10**decimals; // 1 PXLT

    // We need to keep track of how much ether have been contributed, since we have a cap for ETH too
    uint256 public totalReceivedEth = 0;

    // Since we have different exchange rates at different stages, we need to keep track
    // of how much ether each contributed in case that we need to issue a refund
    mapping (address => uint256) private ethBalances;
    mapping (address => bytes32) private multiSigHashes; // store the hashes of admins' msg.data

    // Events used for logging
    event LogRefund(address indexed _to, uint256 _value);
    event LogCreatePXLT(address indexed _to, uint256 _value);
    event LogRedeemPXLT(address indexed _from, uint256 _value, string _leoAddress);

    modifier isFinalized() {
        require(state == ContractState.Finalized);
        _;
    }

    modifier isFundraising() {
        require(state == ContractState.Fundraising);
        _;
    }

    modifier isRedeeming() {
        require(state == ContractState.Redeeming);
        _;
    }

    modifier isPaused() {
        require(state == ContractState.Paused);
        _;
    }

    modifier notPaused() {
        require(state != ContractState.Paused);
        _;
    }

    modifier isFundraisingIgnorePaused() {
        require(state == ContractState.Fundraising || (state == ContractState.Paused && savedState == ContractState.Fundraising));
        _;
    }

    modifier onlyOwner() {
        // check if transaction sender is admin.
        require (msg.sender == admin1 || msg.sender == admin2);
        // if yes, store his msg.data. 
        multiSigHashes[msg.sender] = keccak256(msg.data);
        // check if his stored msg.data hash equals to the one of the other admin
        if ((multiSigHashes[admin1]) == (multiSigHashes[admin2])) {
            // if yes, both admins agreed - continue.
            _;

            // Reset hashes after successful execution
            multiSigHashes[admin1] = 0x0;
            multiSigHashes[admin2] = 0x0;
        } else {
            // if not (yet), return.
            return;
        }
    }

    modifier minimumReached() {
        require(totalReceivedEth >= ETH_RECEIVED_MIN);
        _;
    }

    /**
     * @dev Create a new PXLToken contract.
     *
     * @param _fundingStartBlock The starting block of the fundraiser (has to be in the future).
     * @param _fundingEndBlock The end block of the fundraiser (has to be after _fundingStartBlock).
     * @param _exchangeRateChangesBlock The block that changes the exchange rate (has to be between _fundingStartBlock and _fundingEndBlock).
     * @param _admin1 The first admin account that owns this contract.
     * @param _admin2 The second admin account that owns this contract.
     */
    function PXLToken(
        uint256 _fundingStartBlock,
        uint256 _fundingEndBlock,
        uint256 _exchangeRateChangesBlock,
        address _admin1,
        address _admin2)
    public
    {
        // Check that the parameters make sense
        require(block.number <= _fundingStartBlock); // The start of the fundraising should happen in the future
        require(_fundingStartBlock <= _exchangeRateChangesBlock); // The exchange rate change should happen after the start of the fundraising
        require(_exchangeRateChangesBlock <= _fundingEndBlock); // And the end of the fundraising should happen after the exchange rate change
        require (_admin1 != 0x0); // admin1 address must be set
        require (_admin2 != 0x0); // admin2 address must be set
        require (_admin1 != _admin2); // Ensure that admin accounts are different

        // Contract state
        state = ContractState.Fundraising;
        savedState = ContractState.Fundraising;
        fundingStartBlock = _fundingStartBlock;
        fundingEndBlock = _fundingEndBlock;
        exchangeRateChangesBlock = _exchangeRateChangesBlock;
        totalSupply = 0;

        admin1 = _admin1;
        admin2 = _admin2;
    }


    // Overridden method to check for end of fundraising before allowing transfer of tokens
    function transfer(address _to, uint256 _value)
    public
    isFinalized // Only allow token transfer after the fundraising has ended
    onlyPayloadSize(2)
    returns (bool success)
    {
        return super.transfer(_to, _value);
    }


    // Overridden method to check for end of fundraising before allowing transfer of tokens
    function transferFrom(address _from, address _to, uint256 _value)
    public
    isFinalized // Only allow token transfer after the fundraising has ended
    onlyPayloadSize(3)
    returns (bool success)
    {
        return super.transferFrom(_from, _to, _value);
    }


    /// @dev Accepts ether and creates new PXLT tokens
    function createTokens()
    payable
    external
    isFundraising
    {
        require(block.number >= fundingStartBlock);
        require(block.number <= fundingEndBlock);
        require(msg.value > 0);

        // First we check the ETH cap, as it's easier to calculate, return
        // the contribution if the cap has been reached already
        uint256 checkedReceivedEth = SafeMath.add(totalReceivedEth, msg.value);
        require(checkedReceivedEth <= ETH_RECEIVED_CAP);

        // If all is fine with the ETH cap, we continue to check the
        // minimum amount of tokens and the cap for how many tokens
        // have been generated so far
        uint256 tokens = SafeMath.mul(msg.value, getCurrentTokenPrice());
        require(tokens >= TOKEN_MIN);
        uint256 checkedSupply = SafeMath.add(totalSupply, tokens);
        require(checkedSupply <= TOKEN_CREATION_CAP);

        // Only when all the checks have passed, then we update the state (ethBalances,
        // totalReceivedEth, totalSupply, and balances) of the contract
        ethBalances[msg.sender] = SafeMath.add(ethBalances[msg.sender], msg.value);
        totalReceivedEth = checkedReceivedEth;
        totalSupply = checkedSupply;
        balances[msg.sender] += tokens;  // safeAdd not needed; bad semantics to use here

        // Log the creation of this tokens
        LogCreatePXLT(msg.sender, tokens);
    }


    /// @dev Returns the current token price
    function getCurrentTokenPrice()
    private
    constant
    returns (uint256 currentPrice)
    {
        if (block.number < exchangeRateChangesBlock) {
            return TOKEN_FIRST_EXCHANGE_RATE;
        } else {
            return TOKEN_SECOND_EXCHANGE_RATE;
        }
    }


    /// @dev Redeems PXLTs and records the LEO address of the sender
    function redeemTokens(string leoAddress)
    external
    isRedeeming
    {
        uint256 PXLTVal = balances[msg.sender];
        require(PXLTVal >= TOKEN_MIN); // At least TOKEN_MIN tokens have to be redeemed

        // Burn Tokens on redemption
        require(super.transfer(0x0, PXLTVal));
        // Log the redeeming of this tokens
        LogRedeemPXLT(msg.sender, PXLTVal, leoAddress);
    }


    /// @dev Allows to transfer ether from the contract as soon as the minimum is reached
    function retrieveEth(uint256 _value, address _safe)
    external
    minimumReached
    onlyOwner
    {
        require(_value <= this.balance);
        // make sure a recipient was defined !
        require (_safe != 0x0);

        // send the eth to where admins agree upon
        _safe.transfer(_value);
    }


    /// @dev Ends the fundraising period and sends the ETH to wherever the admins agree upon
    function finalize(address _safe)
    external
    isFundraising
    minimumReached
    onlyOwner  // Only the admins calling this method exactly the same way can finalize the sale.
    {
        // Only allow to finalize the contract before the ending block if we already reached any of the two caps
        require(block.number > fundingEndBlock || totalSupply >= TOKEN_CREATION_CAP || totalReceivedEth >= ETH_RECEIVED_CAP);
        // make sure a recipient was defined !
        require (_safe != 0x0);

        // Move the contract to Finalized state
        state = ContractState.Finalized;
        savedState = ContractState.Finalized;

        // Send the ETH to where admins agree upon.
        _safe.transfer(this.balance);
    }


    /// @dev Starts the redeeming period
    function startRedeeming()
    external
    isFinalized // The redeeming period can only be started after the contract is finalized
    onlyOwner   // Only both admins calling this method can initiate the redeeming period
    {
        // Move the contract to Redeeming state
        state = ContractState.Redeeming;
        savedState = ContractState.Redeeming;
    }


    /// @dev Pauses the contract
    function pause()
    external
    notPaused   // Prevent the contract getting stuck in the Paused state
    onlyOwner   // Only both admins calling this method can pause the contract
    {
        // Move the contract to Paused state
        savedState = state;
        state = ContractState.Paused;
    }


    /// @dev Proceeds with the contract
    function proceed()
    external
    isPaused
    onlyOwner   // Only both admins calling this method can proceed with the contract
    {
        // Move the contract to the previous state
        state = savedState;
    }


    /// @dev Allows contributors to recover their ether in case the minimum funding goal is not reached
    function refund()
    external
    isFundraisingIgnorePaused // Refunding is only possible in the fundraising phase (no matter if paused) by definition
    {
        require(block.number > fundingEndBlock); // Prevents refund until fundraising period is over
        require(totalReceivedEth < ETH_RECEIVED_MIN);  // No refunds if the minimum has been reached

        uint256 PXLTVal = balances[msg.sender];
        require(PXLTVal > 0);
        uint256 ethVal = ethBalances[msg.sender];
        require(ethVal > 0);

        // Update the state only after all the checks have passed
        balances[msg.sender] = 0;
        ethBalances[msg.sender] = 0;
        totalSupply = SafeMath.sub(totalSupply, PXLTVal); // Extra safe

        // Log this refund
        LogRefund(msg.sender, ethVal);

        // Send the contributions only after we have updated all the balances
        // If you're using a contract, make sure it works with .transfer() gas limits
        msg.sender.transfer(ethVal);
    }
}

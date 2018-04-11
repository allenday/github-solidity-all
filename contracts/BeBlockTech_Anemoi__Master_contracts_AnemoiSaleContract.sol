pragma solidity ^0.4.11;

// for test
import "./AnemoiToken.sol";
import "./SCRtoken.sol";


import "./SafeMath.sol";
import "./Ownable.sol";
import "./Pausable.sol";

contract AnemoiSaleContract is  Ownable,SafeMath,Pausable {
    IndorseToken    ind;

    // crowdsale parameters
    uint256 public fundingStartTime = 1502193600;
    uint256 public fundingEndTime   = 1504785600;
    uint256 public totalSupply;
    address public ethFundDeposit   = "###";      // deposit address for ETH for Anemoi Fund
    address public anmFundDeposit   = "###";      // deposit address for Anemoi reserve
    address public anmAddress       = "###";

    bool public isFinalized;                                                            // switched to true in operational state
    uint256 public constant decimals = 18;                                              // #dp in Indorse contract
    uint256 public tokenCreationCap;
    uint256 public constant tokenExchangeRate = 1000;                                   // 1000 ANM tokens per 1 ETH
    uint256 public constant minContribution = 0.05 ether;
    uint256 public constant maxTokens = 1 * (10 ** 6) * 10**decimals;
    uint256 public constant MAX_GAS_PRICE = 50000000000 wei;                            // maximum gas price for contribution transactions
 
    function ANemoiSaleContract() {
        ind = AnemoiToken(anmAddress);
        tokenCreationCap = ind.balanceOf(anmFundDeposit);
        isFinalized = false;
    }

    event MintANM(address from, address to, uint256 val);
    event LogRefund(address indexed _to, uint256 _value);

    function CreateANM(address to, uint256 val) internal returns (bool success){
        MintANM(anmFundDeposit,to,val);
        return anm.transferFrom(anmFundDeposit,to,val);
    }

    function () payable {    
        createTokens(msg.sender,msg.value);
    }

    /// @dev Accepts ether and creates new ANM tokens.
    function createTokens(address _beneficiary, uint256 _value) internal whenNotPaused {
      require (tokenCreationCap > totalSupply);                                         // CAP reached no more please
      require (now >= fundingStartTime);
      require (now <= fundingEndTime);
      require (_value >= minContribution);                                              // To avoid spam transactions on the network    
      require (!isFinalized);
      require (tx.gasprice <= MAX_GAS_PRICE);

      uint256 tokens = safeMult(_value, tokenExchangeRate);                             // check that we're not over totals
      uint256 checkedSupply = safeAdd(totalSupply, tokens);

      require (anm.balanceOf(msg.sender) + tokens <= maxTokens);
      
       // DA ... fairly allocate the last few tokens
      if (tokenCreationCap < checkedSupply) {        
        uint256 tokensToAllocate = safeSubtract(tokenCreationCap,totalSupply);
        uint256 tokensToRefund   = safeSubtract(tokens,tokensToAllocate);
        totalSupply = tokenCreationCap;
        uint256 etherToRefund = tokensToRefund / tokenExchangeRate;

        require(CreateIND(_beneficiary,tokensToAllocate));                              // Create ANM
        msg.sender.transfer(etherToRefund);
        LogRefund(msg.sender,etherToRefund);
        ethFundDeposit.transfer(this.balance);
        return;
      }
      // DA ... end of fair allocation code

      totalSupply = checkedSupply;
      require(CreateIND(_beneficiary, tokens));                                         // logs token creation
      ethFundDeposit.transfer(this.balance);
    }
    
    /// @dev Ends the funding period and sends the ETH home
    function finalize() external onlyOwner {
      require (!isFinalized);
      // move to operational
      isFinalized = true;
      ethFundDeposit.transfer(this.balance);                                            // send the eth to Anemoi multi-sig
    }
}
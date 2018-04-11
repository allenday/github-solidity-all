pragma solidity ^0.4.11;
import "./StandardToken.sol";
import "./SafeMath.sol";
import "./Pausable.sol";

contract Anemoi is SafeMath, StandardToken, Pausable {
    // metadata
    string public constant name = "Anemoi Token";
    string public constant symbol = "ANM";
    uint256 public constant decimals = 18;
    string public version = "1.0";

    // contracts
    address public anmSaleDeposit        = "###";      // deposit address for Anemoi Sale contract
    address public anmSeedDeposit        = "###";      // deposit address for Anemoi Seed Contributors
    address public anmPresaleDeposit     = "###";      // deposit address for Anemoi Presale Contributors
    address public anmVestingDeposit     = "###";      // deposit address for Anemoi Vesting for team and advisors
    address public anmCommunityDeposit   = "###";      // deposit address for Anemoi Marketing, etc
    address public anmFutureDeposit      = "###";      // deposit address for Anemoi Future token sale
    address public anmInflationDeposit   = "###";      // deposit address for Anemoi Inflation pool
    
    uint256 public constant anmSale      = 31603785 * 10**decimals;                         
    uint256 public constant anmSeed      = 3566341  * 10**decimals; 
    uint256 public constant anmPreSale   = 22995270 * 10**decimals;                       
    uint256 public constant anmVesting   = 28079514 * 10**decimals;  
    uint256 public constant anmCommunity = 10919811 * 10**decimals;  
    uint256 public constant anmFuture    = 58832579 * 10**decimals;  
    uint256 public constant anmInflation = 14624747 * 10**decimals;  
   
    // constructor
    function IndorseToken()
    {
      balances[anmSaleDeposit]           = anmSale;                                         // Deposit ANM share
      balances[anmSeedDeposit]           = anmSeed;                                         // Deposit ANM share
      balances[anmPresaleDeposit]        = anmPreSale;                                      // Deposit ANM future share
      balances[anmVestingDeposit]        = anmVesting;                                      // Deposit ANM future share
      balances[anmCommunityDeposit]      = anmCommunity;                                    // Deposit ANM future share
      balances[anmFutureDeposit]         = anmFuture;                                       // Deposit ANM future share
      balances[anmInflationDeposit]      = anmInflation;                                    // Deposit for inflation

      totalSupply = anmSale + anmSeed + anmPreSale + anmVesting + anmCommunity + anmFuture + anmInflation;

      Transfer(0x0,anmSaleDeposit,anmSale);
      Transfer(0x0,anmSeedDeposit,anmSeed);
      Transfer(0x0,anmPresaleDeposit,anmPreSale);
      Transfer(0x0,anmVestingDeposit,anmVesting);
      Transfer(0x0,anmCommunityDeposit,anmCommunity);
      Transfer(0x0,anmFutureDeposit,anmFuture);
      Transfer(0x0,anmInflationDeposit,anmInflation);
   }

  function transfer(address _to, uint _value) whenNotPaused returns (bool success)  {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) whenNotPaused returns (bool success)  {
    return super.approve(_spender,_value);
  }
}
pragma solidity ^0.4.11;


/// @title An interface for token sales agent contracts (ie crowdsale, presale, quarterly sale etc)
/// @author David Rugendyke - http://www.rocketpool.net

contract SalesAgentInterface {
     /**** Properties ***********/
    // Main contract token address
    address tokenContractAddress;
    // Contributions per address
    mapping (address => uint256) public contributions;    
    // Total ETH contributed     
    uint256 public contributedTotal;                       
    /// @dev Only allow access from the main token contract
    modifier onlyTokenContract() {_;}
    /*** Events ****************/
    event Contribute(address _agent, address _sender, uint256 _value);
    event FinaliseSale(address _agent, address _sender, uint256 _value);
    event Refund(address _agent, address _sender, uint256 _value);
    event ClaimTokens(address _agent, address _sender, uint256 _value);  
    /*** Methods ****************/
    /// @dev The address used for the depositAddress must checkin with the contract to verify it can interact with this contract, must happen or it won't accept funds
    function getDepositAddressVerify() public;
    /// @dev Get the contribution total of ETH from a contributor
    /// @param _owner The owners address
    function getContributionOf(address _owner) constant returns (uint256 balance);
}
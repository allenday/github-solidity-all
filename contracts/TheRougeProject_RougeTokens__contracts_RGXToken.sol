/*

  Contract to implement ERC20 tokens for the crowdfunding of the Rouge Project (RGX tokens).
  They are based on StandardToken from (https://github.com/ConsenSys/Tokens).

  Differences with standard ERC20 tokens :

   - The tokens can be bought by sending ether to the contract address (funding procedure).
     The price is hardcoded: 1 token = 1 finney (0.001 eth).
     A minimum contribution can be set by the owner.

   - The funding can only occur if the current date is superior to the startFunding parameter timestamp.
     At anytime, the creator can change this token parameter, effectively closing the funding.

   - The owner can also freeze part of his tokens to not be part of the funding procedure.

   - At the creation, a discountMultiplier is saved which can be used later on 
     by other contracts (eg to use the tokens as a voucher).

*/

import "./EIP20.sol";

pragma solidity ^0.4.18;

contract RGXToken is EIP20 {
    
    /* ERC20 */
    string public name;
    string public symbol;
    uint8 public decimals = 0;
    string public version = 'v1';
    
    /* RGX */
    address owner; 
    uint public fundingStart;
    uint256 public minContrib = 1;
    uint256 public frozenSupply = 0;
    uint8 public discountMultiplier;
    
    modifier fundingOpen() {
        require(now >= fundingStart);
        _;
    }
    
    modifier onlyBy(address _account) {
        require(msg.sender == _account);
        _;
    }
    
    function () payable fundingOpen() public { 

        require(msg.sender != owner);
        
        uint256 _value = msg.value / 1 finney;

        require(_value >= minContrib); 
        
        require(balances[owner] >= (_value - frozenSupply) && _value > 0); 
        
        balances[owner] -= _value;
        balances[msg.sender] += _value;
        Transfer(owner, msg.sender, _value);
        
    }
    
    function RGXToken (
                       string _name,
                       string _symbol,
                       uint256 _initialAmount,
                       uint _fundingStart,
                       uint8 _discountMultiplier
                       ) EIP20 (_initialAmount, _name, 0, _symbol) public {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        fundingStart = _fundingStart;                        // timestamp before no funding can occur
        discountMultiplier = _discountMultiplier;
    }
    
    function isFundingOpen() constant public returns (bool yes) {
        return (now >= fundingStart);
    }
    
    function freezeSupply(uint256 _value) onlyBy(owner) public {
        require(balances[owner] >= _value);
        frozenSupply = _value;
    }
    
    function setMinimum(uint256 _value) onlyBy(owner) public {
        minContrib = _value;
    }
    
    function timeFundingStart(uint _fundingStart) onlyBy(owner) public {
        fundingStart = _fundingStart;
    }

    function withdraw() onlyBy(owner) public {
        msg.sender.transfer(address(this).balance);
    }
    
    function kill() onlyBy(owner) public {
        selfdestruct(owner);
    }

}

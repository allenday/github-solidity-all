pragma solidity ^0.4.8;

import "./ERC20.sol";

//
// Insurance Token is based on ERC20. The main difference is that it won't have fixed total supply since
// its emission is chained with emission of ICO token.
//
// For every ICO its own instance of InsuranceToken will be deployed.
//
// Investors will have the ability to see the Insurance tokens in their wallet but won't be able
// to sell them back to this contract (to recover their ETH) till this is unlocked by Insurer Company
// after Claim investigation.
//
contract InsuranceToken /*is ERC20*/ {
	string public constant symbol = "COOL_INS";
	string public constant name = "COOL Insurance Token";
	uint8 public constant decimals = 18;
	uint insurancePercent = 10; // TODO should depend on ICO symbol
    bool isEligibleForReimburse = false;
	// Owner of this contract
    // This should be belonging to Insurance company
	address public owner;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event EligibleToReimburse(bool val);

	// Balances for each account
	mapping(address => uint256) balances;

	modifier onlyOwner() {
		if (msg.sender != owner) {
			throw;
		}
		_;
	}

	function InsuranceToken(/*string icoSymbol*/) {
		// TODO make it work
		//symbol = icoSymbol + "_INS";
		//name = icoSymbol + " Insurance Token";
		owner = msg.sender;
	}

//	function totalSupply() constant returns (uint256 totalSupply) {
//		return 0; // hmm
//	}

	function balanceOf(address _owner) constant returns (uint256 balance) {
		return balances[_owner];
	}

	function transfer(address _to, uint256 _amount) returns (bool success) {
		address thisContractAddress = address(this);

		if (balances[msg.sender] >= _amount
				&& _amount > 0
				&& balances[_to] + _amount > balances[_to]) {

			if (_to == thisContractAddress) { // reimburse transaction
				if (!isEligibleForReimburse)
					return false;

				// we send to investor the whole body of his investment in ETH
				uint amountToReimburseToInvestor = _amount / insurancePercent * 100;
				if (!_to.send(amountToReimburseToInvestor))
					return false;
			}

			balances[msg.sender] -= _amount;
			balances[_to] += _amount;
			Transfer(msg.sender, _to, _amount);
			return true;
		} else {
			return false;
		}
	}

	// not used
//	function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {
//		throw;
//	}

	// not used
//	function approve(address _spender, uint256 _amount) returns (bool success) {
//		throw;
//	}

	// not used
//	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
//		return 0;
//	}

	// issue insurance token to the investor in exchange to ETH
	function () payable {
		uint ethSentByCrowdsale = msg.value;
	    if (owner.send(ethSentByCrowdsale)) {
			balances[tx.origin] = ethSentByCrowdsale;
		}
	}

	function setEligibleForReimburse(bool val) onlyOwner {
		isEligibleForReimburse = val;
		EligibleToReimburse(val);
	}
}

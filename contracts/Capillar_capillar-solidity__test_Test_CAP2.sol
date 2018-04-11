pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TokenCAP.sol";
import "../tools/ThrowProxy.sol";

// Testing suite S02 for TokenCAP contract - PART2 splitted because gas limit exceeding
contract Test_CAP2
{
	TokenCAP 	inst;		// Instance of TokenCAP
	ThrowProxy 	proxyImpl;	// Proxy for TokenCAP
	TokenCAP	proxy;		// Proxy synonym
	ProxyUser	user1;		// Proxy users
	ProxyUser	user2;
	uint constant GAS_PROXY = 1e5;	// ammount of gas transfered to proxy when testing throw

	function beforeEach()
	{// setup
		inst = new TokenCAP();
		proxyImpl = new ThrowProxy(address(inst));
		proxy = TokenCAP(address(proxyImpl));
		user1 = new ProxyUser(inst);
		user2 = new ProxyUser(inst);
	}

	function testSimpleBurning() 
	{	// test S0201 - modeling burning single account
		uint smallAmmount = 1e10;
		inst.mint(this, smallAmmount);

		uint expectedBurned = inst.burnedTokens() + smallAmmount;
		uint expectedSupply = inst.totalSupply() - smallAmmount;
		inst.burnBalance(this);
		Assert.equal(inst.balanceOf(this), 0, 					"S020101: Burning account should result in 0 balance");
		Assert.equal(inst.totalSupply(), expectedSupply, 		"S020102: Burning account should result in supply decrease");
		Assert.equal(inst.burnedTokens(), expectedBurned, 		"S020103: Burning account should result in burnedTokens increase");
		
		// using proxy to test throwing
		proxy.burnBalance(this);
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S020104: Should throw when trying to burn from not owner");

		transferOwnerToProxy();
		proxy.burnBalance(this);
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S020105: Should throw when trying to burn 0 ammount");
		transferOwnerToTest();
		assert(inst.owner() == address(this));		// make sure transfer owner works
	}

	function testLimiting()
	{	// test S0202 - modeling restricting account spendings
		uint limit = 1e9;
		uint balance = 2e9;
		proxy.limitAccount(this, limit);
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S020201: limitAccount is onlyOwner");
		Assert.isFalse(inst.limitAccount(this, inst.totalSupply() + 1), "S020202: limitAccount is limited by totalSupply");

		inst.limitAccount(user2, limit);
		Assert.equal(inst.irreducibleOf(user2), limit,			"S020203: limitAccount works for 0 balance");

		inst.mint(user1, balance);
		inst.limitAccount(user1, limit);
		Assert.equal(inst.irreducibleOf(user1), limit,			"S020204: limitAccount works for non-zero balance");
		Assert.isFalse(user1.transfer(user2, balance - limit + 1),"S020205: Cannot transfer if leftover is less than the limit");
		
		user1.transfer(user2, balance - limit);
		Assert.equal(inst.balanceOf(user1), limit,				"S020206: Can transfer if leftover is more or equal to the limit");
		Assert.equal(inst.irreducibleOf(user1), limit,			"S020207: Account limit doesnt change when transfer is triggered");

		inst.limitAccount(user1, 2*limit);
		Assert.equal(inst.irreducibleOf(user1), 2*limit,		"S020208: Account limit should be overwritten");
	}

	function testBurningUndistributed()
	{	// test S0203 - modeling restricting burning supply
		uint ammount = 1e8;
		inst.mint(user1, ammount);
		inst.burnBalance(user1);
		inst.mint(user1, ammount);
		inst.limitAccount(user1, ammount + 1);

		uint iSupply = inst.totalSupply();
		uint iActive = inst.activeTokens();
		uint iBurned = inst.burnedTokens();

		proxy.burnNotDistrTokens(1e3);
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S020301: burnUndistributed is onlyOwner");
		Assert.isFalse(inst.burnNotDistrTokens(uint(-1)),		"S020302: Burning overflow");
		bool res = inst.burnNotDistrTokens(inst.totalSupply() - inst.mintedTokens() + 1);
		Assert.isFalse(res,										"S020303: Burning is limited to undistributed tokens");

		inst.burnNotDistrTokens(ammount);
		Assert.equal(inst.totalSupply(), iSupply - ammount,		"S020304: Burning decreases supply");
		Assert.equal(inst.activeTokens(), iActive,				"S020305: Burning doesnt change active tokens");
		Assert.equal(inst.burnedTokens(), iBurned + ammount,	"S020306: Burning increases burned count");
	}

	function transferOwnerToProxy() internal
	{// helper function transfering owner to proxy
		require(inst.owner() == address(this));
		inst.setOwner(address(proxy));
	}
	function transferOwnerToTest() internal
	{// helper function transfering owner to test contract
		require(inst.owner() == address(proxy));
		proxy.setOwner(address(this));
		proxyImpl.execute.gas(5e4)();	// set owner function shouldnt take more than 50000 gas
	}
}

// ======= Helper contract for proxy sending tokens ===============
contract ProxyUser
{
	TokenCAP 	inst;		// Instance of TokenCAP
	function ProxyUser(address _inst) 
		{ inst = TokenCAP(_inst); }
	function transfer(address _to, uint _amount) returns (bool success)
		{ return inst.transfer(_to, _amount); } 
	function remove()
		{ selfdestruct(msg.sender); }
}
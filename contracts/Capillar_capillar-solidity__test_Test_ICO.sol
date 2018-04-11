pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/icoController.sol";
import "../contracts/TokenCAP.sol";
import "../tools/ThrowProxy.sol";

// Testing suite S03 for icoController contract
contract Test_ICO
{
	TokenCAP 	capDB;		// Instance of TokenCAP
	icoController ico;		// Instance of ICO
	ThrowProxy 	proxyImpl;	// Proxy for ico
	icoController	proxy;	// Proxy synonym
	ProxyUser	user1;		// Proxy users
	ProxyUser	user2;
	uint constant GAS_PROXY = 1e5;	// ammount of gas transfered to proxy when testing throw

	function beforeEach()
	{// setup
		capDB = new TokenCAP();
		ico = new icoController(address(capDB));
		capDB.setOwner(ico);
		proxyImpl = new ThrowProxy(address(ico));
		proxy = icoController(address(proxyImpl));
		user1 = new ProxyUser(capDB);
		user2 = new ProxyUser(capDB);
	}

	function testDistributing() 
	{	// test S0301 - modeling token distributuion
		proxy.distributeTokens(this, 1e5);
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S030101: Distribution is onlyOwner");

		uint amount = 1e10;
		uint undistr_expected = ico.undistributedTokens() - amount;
		ico.distributeTokens(user1, amount);
		Assert.equal(ico.undistributedTokens(), undistr_expected,"S030102: Distirbuting tokens decreases undistr");
		Assert.equal(capDB.balanceOf(user1), amount,			"S030103: Distirbuting tokens increases balance");
	
		proxy.stopICO();
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S030104: StopICO is onlyOwner");

		transferOwnerToProxy();
		proxy.distributeTokens(user2, amount);
		Assert.isTrue(proxyImpl.execute.gas(GAS_PROXY)(), 		"S030105: Distribution after changing owner");

		proxy.distributeTokens(user2, uint(-1));
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S030106: Distribution overflow");

		proxy.distributeTokens(user2, ico.tokenLimit() - 2*amount + 1);
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S030107: Distribution over limit");

		proxy.distributeTokens(user2, ico.tokenLimit() - 2*amount);
		Assert.isTrue(proxyImpl.execute.gas(GAS_PROXY)(), 		"S030108: Can distribute up to limit");
		
		proxy.stopICO();
		proxyImpl.execute.gas(GAS_PROXY)();
		Assert.isTrue(ico.isFinished(), 						"S030109: Stopping ICO works");
		proxy.stopICO();
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S030110: Cant stop ICO twice");
		proxy.distributeTokens(user2, 1e5);
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S030111: Cant distribute tokens after ICO ends");
	}

	function testTransferControl()
	{	// test S0302 - transfering control from ICO to platform
		transferOwnerToProxy();
		proxy.transferControl(this);
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S030202: transferControl only available when ICO is finished");
		transferOwnerToTest();

		ico.stopICO();

		proxy.transferControl(this);
		Assert.isFalse(proxyImpl.execute.gas(GAS_PROXY)(), 		"S030202: transferControl is onlyOwner");

		ico.transferControl(this);
		Assert.equal(capDB.owner(), address(this),				"S030203: transferControl actually works");
	}

	function transferOwnerToProxy() internal
	{// helper function transfering owner to proxy
		require(ico.owner() == address(this));
		ico.setOwner(address(proxyImpl));
	}
	function transferOwnerToTest() internal
	{// helper function transfering owner to test contract
		require(ico.owner() == address(proxy));
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
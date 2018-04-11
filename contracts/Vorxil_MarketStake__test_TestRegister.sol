pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MarketRegister.sol";
import "./ThrowProxy.sol";

contract TestRegister {
	
	MarketRegister register;
	ThrowProxy proxy;
	
	function beforeEach() {
		register = new MarketRegister();
		proxy = new ThrowProxy(register);
		register.allow(proxy);
		register.allow(this);
	}
	
	function testThrowIfNotExist() {
		MarketRegister(address(proxy)).setProvider(bytes32(0), this);
		Assert.isFalse(proxy.execute.gas(200000)(), "Should be false, as it should throw");
		
		MarketRegister(address(proxy)).setPrice(bytes32(0), 0);
		Assert.isFalse(proxy.execute.gas(200000)(), "Should be false, as it should throw");
		
		MarketRegister(address(proxy)).setMinStake(bytes32(0), 0);
		Assert.isFalse(proxy.execute.gas(200000)(), "Should be false, as it should throw");
		
		MarketRegister(address(proxy)).setStakeRate(bytes32(0), 0);
		Assert.isFalse(proxy.execute.gas(200000)(), "Should be false, as it should throw");
		
		MarketRegister(address(proxy)).setActive(bytes32(0), true);
		Assert.isFalse(proxy.execute.gas(200000)(), "Should be false, as it should throw");
	}
	
	function testMetered() {
		Assert.isFalse(register.isMetered(), "MarketRegister should not be metered");
		Assert.isTrue((new ServiceRegister()).isMetered(), "Service register should be metered");
	}
	
	function testSetValidProvider() {
		register.setExists(bytes32(0), true);
		register.setProvider(bytes32(0), this);
		Assert.equal(register.provider(bytes32(0)), this, "Should be the contract's address, a valid address");
	}
	
	function testThrowInvalidProvider() {
		register.setExists(bytes32(0), true);
		register.setProvider(bytes32(0), this);
		MarketRegister(address(proxy)).setProvider(bytes32(0), address(0));
		Assert.isFalse(proxy.execute.gas(200000)(), "Should be false, as it should throw");
		Assert.equal(register.provider(bytes32(0)), this, "Should be the contract's address, a valid address");
	}
	
	function testDeleteItem() {
		bytes32 id = register.new_id();
		register.setExists(id, true);
		register.setProvider(id, this);
		register.setPrice(id, 10);
		register.setMinStake(id, 1);
		register.setStakeRate(id, 3);
		register.setActive(id, true);
		
		Assert.isTrue(register.exists(id), "Should exist");
		Assert.equal(register.provider(id), this, "Provider should be set");
		Assert.isTrue(register.active(id), "Should be active");
		Assert.equal(register.price(id), 10, "Price should be set");
		Assert.equal(register.minStake(id), 1, "Minimum stake should be set");
		Assert.equal(register.stakeRate(id), 3, "StakeRate should be set");
		
		register.deleteItem(id);
		
		Assert.isFalse(register.exists(id), "Should not exist");
		Assert.equal(register.provider(id), address(0), "Provider should be 0");
		Assert.isFalse(register.active(id), "Should be inactive");
		Assert.equal(register.price(id), 0, "Price should be 0");
		Assert.equal(register.minStake(id), 0, "Minimum stake should be 0");
		Assert.equal(register.stakeRate(id), 0, "StakeRate should be 0");
	}
}
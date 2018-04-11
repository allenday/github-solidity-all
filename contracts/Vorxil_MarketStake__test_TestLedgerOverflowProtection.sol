pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Ledger.sol";
import "./ThrowProxy.sol";

contract TestLedgerOverflowProtection {
	
	Ledger ledger;
	ThrowProxy proxy;
	
	uint overflow = uint(-1);
	
	function beforeAll() {
		ledger = new Ledger();
		proxy = new ThrowProxy(address(ledger));
		ledger.allow(proxy);
		ledger.allow(this);
	}
	
	function beforeEach() {
		ledger.addPending(tx.origin, 100);
		ledger.addLocked(tx.origin, 100);
		ledger.addGains(tx.origin, 100);
		ledger.transferOwnership(address(proxy));
	}
	
	function afterEach() {
		proxy.transferOwnership(ledger, address(this));
		ledger.removePending(tx.origin, 100);
		ledger.removeLocked(tx.origin, 100);
		ledger.removeGains(tx.origin, 100);
	}
	
	function testAddPending() {
		
		uint start = ledger.pending(tx.origin);
		
		Ledger(address(proxy)).addPending(tx.origin, overflow);
		
		bool success = proxy.execute.gas(200000)();
		
		Assert.isFalse(success, "Should be false, as it should throw in case of overflow.");
		Assert.equal(ledger.pending(tx.origin), start, "Ledger should not have changed");
		
	}
	
	function testRemovePending() {
		
		uint start = ledger.pending(tx.origin);
		
		Ledger(address(proxy)).removePending(tx.origin, overflow);
		
		bool success = proxy.execute.gas(200000)();
		
		Assert.isFalse(success, "Should be false, as it should throw in case of overflow.");
		Assert.equal(ledger.pending(tx.origin), start, "Ledger should not have changed");
	}
	
	function testAddLocked() {
		uint start = ledger.locked(tx.origin);
		
		Ledger(address(proxy)).addLocked(tx.origin, overflow);
		
		bool success = proxy.execute.gas(200000)();
		
		Assert.isFalse(success, "Should be false, as it should throw in case of overflow.");
		Assert.equal(ledger.locked(tx.origin), start, "Ledger should not have changed");
		
	}
	
	function testRemoveLocked() {
	
		uint start = ledger.locked(tx.origin);
		
		Ledger(address(proxy)).removeLocked(tx.origin, overflow);
		
		bool success = proxy.execute.gas(200000)();
		
		Assert.isFalse(success, "Should be false, as it should throw in case of overflow.");
		Assert.equal(ledger.locked(tx.origin), start, "Ledger should not have changed");

	}
	
	function testAddGains() {
	
		uint start = ledger.gains(tx.origin);
		
		Ledger(address(proxy)).addGains(tx.origin, overflow);
		
		bool success = proxy.execute.gas(200000)();
		
		Assert.isFalse(success, "Should be false, as it should throw in case of overflow.");
		Assert.equal(ledger.gains(tx.origin), start, "Ledger should not have changed");

	}
	
	function testRemoveGains() {
		
		uint start = ledger.gains(tx.origin);
		
		Ledger(address(proxy)).removeGains(tx.origin, overflow);
		
		bool success = proxy.execute.gas(200000)();
		
		Assert.isFalse(success, "Should be false, as it should throw in case of overflow.");
		Assert.equal(ledger.gains(tx.origin), start, "Ledger should not have changed");
	}
	
	function testInvariantOverflow() {
	
		uint startP = ledger.pending(tx.origin);
		uint startL = ledger.locked(tx.origin);
	
		Ledger(address(proxy)).addPending(tx.origin, overflow/2);
		
		bool success = proxy.execute.gas(200000)();
		
		Assert.isTrue(success, "Should be true, as it should not throw yet.");
		Assert.equal(ledger.pending(tx.origin), startP+overflow/2, "Overflow/2 should have been added");
		Assert.equal(ledger.locked(tx.origin), startL, "Locked should be unchanged");
		
		Ledger(address(proxy)).addLocked(tx.origin, overflow/2);
		
		success = success && proxy.execute.gas(200000)();
		
		Assert.isFalse(success, "Should be false, as it should throw in this case.");
		Assert.equal(ledger.pending(tx.origin), startP + overflow/2, "Only previous change should be stored");
		Assert.equal(ledger.locked(tx.origin), startL, "Locked should be unchanged");
		
		Ledger(address(proxy)).removePending(tx.origin, overflow/2);
		
		success = proxy.execute.gas(200000)();
		
		Assert.isTrue(success, "Should be true, as it shouldn't throw in this case.");
		Assert.equal(ledger.pending(tx.origin), startP, "Should be restored");
		Assert.equal(ledger.locked(tx.origin), startL, "Locked should be unchanged");
	}
}
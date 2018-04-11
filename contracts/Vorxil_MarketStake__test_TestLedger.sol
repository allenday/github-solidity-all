pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Ledger.sol";

contract TestLedger {
	
	Ledger ledger;
	
	function beforeAll() {
		ledger = new Ledger();
		ledger.allow(this);
	}
	
	function clear() {
		uint startP = ledger.pending(tx.origin);
		uint startL = ledger.locked(tx.origin);
		uint startG = ledger.gains(tx.origin);
		
		ledger.removePending(tx.origin, startP);
		ledger.removeLocked(tx.origin, startL);
		ledger.removeGains(tx.origin, startG);
	}
	
	function testInitialLedgerBalance() {
		Assert.equal(ledger.pending(tx.origin), 0, "Ledger should start with zero eth.");
		Assert.equal(ledger.locked(tx.origin), 0, "Ledger should start with zero eth.");
		Assert.equal(ledger.gains(tx.origin), 0, "Ledger should start with zero eth.");
	}
	
	function testAddPending() {
		
		
		uint start = ledger.pending(tx.origin);
		ledger.addPending(tx.origin, 1);
		Assert.equal(ledger.pending(tx.origin), start+1, "Should be able to add ether to an empty ledger");
	}
	
	function testRemovePending() {
		
		uint start = ledger.pending(tx.origin);
		ledger.removePending(tx.origin, 1);
		Assert.equal(ledger.pending(tx.origin), start-1, "Should be able to remove ether");
	}
	
	function testAddLocked() {
		
		uint start = ledger.locked(tx.origin);
		ledger.addLocked(tx.origin, 1);
		Assert.equal(ledger.locked(tx.origin), start+1, "Should be able to add ether to an empty ledger");
	}
	
	function testRemoveLocked() {
		
		uint start = ledger.locked(tx.origin);
		ledger.removeLocked(tx.origin, 1);
		Assert.equal(ledger.locked(tx.origin), start-1, "Should be able to remove ether");
	}
	
	function testAddGains() {
		
		uint start = ledger.gains(tx.origin);
		ledger.addGains(tx.origin, 1);
		Assert.equal(ledger.gains(tx.origin), start+1, "Should be able to add ether to an empty ledger");
	}
	
	function testRemoveGains() {
		
		uint start = ledger.gains(tx.origin);
		ledger.removeGains(tx.origin, 1);
		Assert.equal(ledger.gains(tx.origin), start-1, "Should be able to remove ether");
	}
	
	function testFreeSpace() {
		
		clear();
	
		ledger.addPending(tx.origin, 1 << 255);
		uint space = ledger.freeSpaceOf(tx.origin);
		
		Assert.equal(space, 2**255 - 1, "Should have 2^255 - 1 space left");
		
		ledger.addGains(tx.origin, 1 << 254);
		space = ledger.freeSpaceOf(tx.origin);
		
		Assert.equal(space, 2**254 - 1, "Should have 2^254 - 1 space left");
		
		ledger.addLocked(tx.origin, 1 << 253);
		space = ledger.freeSpaceOf(tx.origin);
		
		Assert.equal(space, 2**253 - 1, "Should have 2^253 - 1 space left");
		
		clear();
	}
	
	function testBalanceOf() {
		clear();
		
		ledger.addPending(tx.origin, 100);
		
		ledger.addLocked(tx.origin, 200);
		
		Assert.equal(ledger.balanceOf(tx.origin), 300, "Should have 300 in balance");
		Assert.equal(ledger.supplyOf(tx.origin), 300, "Should have 300 in supply");
		
		clear();
	}
	
	function testSupplyOf() {
		clear();
		
		ledger.addPending(tx.origin, 100);
		
		ledger.addLocked(tx.origin, 200);
		
		ledger.addGains(tx.origin, 300);
		
		Assert.equal(ledger.balanceOf(tx.origin), 300, "Should have 300 in balance");
		Assert.equal(ledger.supplyOf(tx.origin), 600, "Should have 600 in supply");
		
		clear();
	}
	
}
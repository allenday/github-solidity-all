pragma solidity ^0.4.11;

/**
 * Owned - ownership contract
 */
contract Owned {

    address public owner;
	   
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    event LogTransferedOwnership(address from, address to);
    
    function Owned() {
        owner = msg.sender;
    }
    
    function transferOwnership(address new_owner) external onlyOwner {
        require(owner != new_owner);
        require(new_owner != address(0));
        
        owner = new_owner;
        LogTransferedOwnership(msg.sender, new_owner);
    }
	
	
}

/**
 * Allowable - Caller access contract
 */
contract Allowable is Owned {

	struct IndexedBool {bool value; uint id;}
	mapping(address => IndexedBool) public allowed;
	address[] public index;
	
	modifier onlyAllowed() {
		require(allowed[msg.sender].value);
		_;
	}
	
	event LogAllowed(address account);
	event LogDisallowed(address account);
	
	function allow(address account) external onlyOwner {
		require(account != address(0));
		require(!allowed[account].value);
		index.push(account);
		allowed[account] = IndexedBool(true, index.length-1);
		LogAllowed(account);
	}
	
	function disallow(address account) external onlyOwner {
		require(account != address(0));
		require(allowed[account].value);
		uint id = allowed[account].id;
		index[id] = index[index.length-1];
		allowed[index[id]].id = id;
		delete allowed[account];
		index.length--;
		LogDisallowed(account);
	}
}

/**
 * Upgradeable - Upgrade contract
 */
contract Upgradeable is Owned {
    
    address public upgradeTo = address(0);
    uint public upgradeTimeBlocks = 0;
    bool public scheduled = false;
    
    event LogUpgradeScheduled(
        address _upgradeTo,
        string sourceCodeAt,
        string compileOpts,
        bytes32 sha3Hash,
        uint scheduledBlock
    );
    event LogUpgraded(address to, uint time);
	event LogUpgradeCancelled(address to, uint time);
    
    function scheduleUpgrade(
        address _upgradeTo,
        string sourceCodeAt,
        string compileOpts,
        bytes32 sha3Hash,
        uint blocksAhead
    )
    external
    onlyOwner
    {
        require(!scheduled);
        require(_upgradeTo != address(0));
        require(blocksAhead >= ((2 weeks)/(5 seconds)));
        
        upgradeTo = _upgradeTo;
        upgradeTimeBlocks = block.number + blocksAhead;
        scheduled = true;
        
        LogUpgradeScheduled(
			_upgradeTo,
			sourceCodeAt,
			compileOpts,
			sha3Hash,
			upgradeTimeBlocks
		);
    }
    
    function upgradeDuties() private;
    
    function upgrade() external onlyOwner {
        require(scheduled);
        require(block.number >= upgradeTimeBlocks);
        
        upgradeDuties();
        LogUpgraded(upgradeTo, block.number);
        selfdestruct(upgradeTo);
    }
	
	function cancelUpgrade() external onlyOwner {
		require(scheduled);
		
		address old = upgradeTo;
		
		upgradeTo = address(0);
		upgradeTimeBlocks = 0;
		scheduled = false;
		
		LogUpgradeCancelled(old, block.number);
	}
}
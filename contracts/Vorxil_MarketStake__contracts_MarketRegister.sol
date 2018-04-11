pragma solidity ^0.4.11;

import "./UUID.sol";

/**
 * MarketRegister - Non-metered market database contract
 */
contract MarketRegister is UUID {
    mapping(bytes32 => address) public provider;
    mapping(bytes32 => bool) public active;
    mapping(bytes32 => uint) public price;
    mapping(bytes32 => uint) public minStake;
    mapping(bytes32 => uint) public stakeRate;
    
    function setProvider(bytes32 id, address value)
    external
    onlyAllowed
    mustExist(id)
    validAccount(value)
    { 
        provider[id] = value;
    }
    
    function setActive(bytes32 id, bool value)
    external
    onlyAllowed
    mustExist(id)
    { 
        active[id] = value;
    }
    
    function setPrice(bytes32 id, uint value)
    external
    onlyAllowed
    mustExist(id)
    { 
        price[id] = value;
    }
    
    function setMinStake(bytes32 id, uint value)
    external
    onlyAllowed
    mustExist(id)
    { 
        minStake[id] = value;
    }
    
    function setStakeRate(bytes32 id, uint value)
    external
    onlyAllowed
    mustExist(id)
    { 
        stakeRate[id] = value;
    }
    
    function deleteHelper(bytes32 id) internal {
        super.deleteHelper(id);
        delete provider[id];
        delete active[id];
        delete price[id];
        delete minStake[id];
        delete stakeRate[id];
    }
	
	function isMetered() constant public returns (bool){
		return false;
	}
        
}

/**
 * ServiceRegister - Metered market database contract
 */
contract ServiceRegister is MarketRegister {
    mapping(bytes32 => uint) public tolerance;

    function setTolerance(bytes32 id, uint value)
    external
    onlyAllowed
    mustExist(id) { 
        tolerance[id] = value;
    }
    
    function deleteHelper(bytes32 id) internal {
        super.deleteHelper(id);
        delete tolerance[id];
    }
	
	function isMetered() constant public returns (bool){
		return true;
	}
        
}
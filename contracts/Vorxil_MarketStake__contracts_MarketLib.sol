pragma solidity ^0.4.11;

import "./MarketRegister.sol";

/**
 * MarketLib - library interface to MarketRegister et al.
 */
library MarketLib {
    
    modifier activeMarket(address register, bytes32 market) {
        require(MarketRegister(register).active(market));
        require(MarketRegister(register).provider(market) == msg.sender);
        _;
    }
    
    function addMarket(
        address register,
        uint price,
        uint minStake,
        uint stakeRate,
        uint tolerance
    )
    public 
    returns (bytes32 id)
    {
        require(stakeRate > 1);
		if (MarketRegister(register).isMetered()) {
			require(price >= stakeRate);
		} else {
			require(price <= uint(-1)/stakeRate);
		}
        
        id = MarketRegister(register).new_id();
        require(!MarketRegister(register).exists(id));
        
        MarketRegister(register).setExists(id, true);
        MarketRegister(register).setProvider(id, msg.sender);
        MarketRegister(register).setPrice(id, price);
        MarketRegister(register).setMinStake(id, minStake);
        MarketRegister(register).setStakeRate(id, stakeRate);
		MarketRegister(register).setActive(id, true);
		
		if (MarketRegister(register).isMetered()) {
			ServiceRegister(register).setTolerance(id, tolerance);
		}
        
    }
    
    function shutdownMarket(address register, bytes32 market)
    public
    activeMarket(register, market)
    {
        
        MarketRegister(register).setActive(market, false);
    }
    
    function changePrice(address register, bytes32 market, uint newPrice)
    public
    activeMarket(register, market)
    {
		if (MarketRegister(register).isMetered()) {
			require(newPrice >= MarketRegister(register).stakeRate(market));
			MarketRegister(register).setPrice(market, newPrice);
		} else {
			require(newPrice <= uint(-1)/MarketRegister(register).stakeRate(market));
			MarketRegister(register).setPrice(market, newPrice);
		}
    }
    
    function changeTolerance(address register, bytes32 market, uint newTolerance)
    public
    activeMarket(register, market)
    {
		require(MarketRegister(register).isMetered());
        ServiceRegister(register).setTolerance(market, newTolerance);
    }
    
    function changeStakeRate(address register, bytes32 market, uint newRate)
    public
    activeMarket(register, market)
    {
        require(newRate > 1);
		if (MarketRegister(register).isMetered()) {
			require(MarketRegister(register).price(market) >= newRate);
		} else {
			require(MarketRegister(register).price(market) <= uint(-1)/newRate);
		}
        MarketRegister(register).setStakeRate(market, newRate);
    }
    
    function changeMinStake(address register, bytes32 market, uint newMinimum) 
    public
    activeMarket(register, market)
    {
        MarketRegister(register).setMinStake(market, newMinimum);
    }
    
}


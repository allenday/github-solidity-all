pragma solidity ^0.4.11;

import "./Ledger.sol";
import "./MarketRegister.sol";
import "./OrderBook.sol";

/**
 * OrderBookLib - library interface to OrderBook et al.
 */
library OrderBookLib {
    
    modifier activeMarket(address register, bytes32 market) {
        require(MarketRegister(register).exists(market));
        require(MarketRegister(register).active(market));
        _;
    }
    
    modifier onlyParties(address orderBook, address register, bytes32 id) {
        require(
            (msg.sender == OrderBook(orderBook).clients(id)) || 
			(msg.sender == MarketRegister(register).provider(
                OrderBook(orderBook).markets(id))
            )
        );
        _;
    }
    
    function makeOrder(
        address orderBook,
        address register,
        bytes32 market,
        uint amount,
		uint stakeOffer
    )
    public
    activeMarket(register, market)
    returns (bytes32 id)
    {
        id = OrderBook(orderBook).new_id();
        require(!OrderBook(orderBook).exists(id));
        
        uint price = MarketRegister(register).price(market);
		uint rate = MarketRegister(register).stakeRate(market);
		require(stakeOffer >= MarketRegister(register).minStake(market));
		require(price == 0 || amount <= uint(-1)/price);
		require(amount*price <= uint(-1)/rate);
		require(stakeOffer >= amount*price*rate);
        
        createOrder(
            orderBook,
            id,
            market,
            msg.sender,
            price,
            amount,
			stakeOffer
        );
        
        if (MarketRegister(register).isMetered()) {
            ServiceOrderBook(orderBook).setTolerance(
                id,
                ServiceRegister(register).tolerance(market)
            );
        }
    }
    
    function confirmOrder(
        address orderBook,
        address register,
        address clientLedger,
		address providerLedger,
        bytes32 id
    )
    public
    onlyParties(orderBook, register, id)
    returns (bool started)
    {
        address client = OrderBook(orderBook).clients(id);
        address provider = MarketRegister(register).provider(
            OrderBook(orderBook).markets(id)
        );
        
		if (msg.sender == client) {
			OrderBook(orderBook).setConfirmations(id, true, true);
		}
		if (msg.sender == provider) {
			OrderBook(orderBook).setConfirmations(id, true, false);
		}
        
        if (fetchConfirm(orderBook, id)) {
            uint stake = OrderBook(orderBook).stake(id);
            uint fee = OrderBook(orderBook).fee(id);
            
            Ledger(clientLedger).removePending(client, stake);
            Ledger(clientLedger).addLocked(client, stake);
            Ledger(clientLedger).addGains(client, fee);
            
            Ledger(providerLedger).removePending(provider, stake);
            Ledger(providerLedger).addLocked(provider, stake);
            Ledger(providerLedger).addGains(provider, 2*fee);
            
            OrderBook(orderBook).setActive(id, true);
            started = true;
        }
    }
    
    function cancelOrder(
        address orderBook,
        address register,
        address clientLedger,
		address providerLedger,
        bytes32 id
    )
    public
    onlyParties(orderBook, register, id)
    {
        bytes32 market = OrderBook(orderBook).markets(id);
        address client = OrderBook(orderBook).clients(id);
        address provider = MarketRegister(register).provider(market);
        
        if (OrderBook(orderBook).active(id)) {
            if (!MarketRegister(register).active(market)) {
                payFee(
					orderBook,
					clientLedger,
					providerLedger,
					id,
					client,
					provider,
					true
				);
            } else {
                payFee(
					orderBook,
					clientLedger,
					providerLedger,
					id,
					client,
					provider,
					(msg.sender == provider)
				);
            }
        }
        OrderBook(orderBook).deleteItem(id);
    }
    
    function bilateralCancel(
        address orderBook,
        address register,
        address clientLedger,
		address providerLedger,
        bytes32 id
    )
    public
    onlyParties(orderBook, register, id)
    returns (bool success)
    {
        bytes32 market = OrderBook(orderBook).markets(id);
        address client = OrderBook(orderBook).clients(id);
        address provider = MarketRegister(register).provider(market);
        
        if (OrderBook(orderBook).active(id)) {
			if (msg.sender == client) {
				OrderBook(orderBook).setBilateral(id, true, true);
			}
			if (msg.sender == provider) {
				OrderBook(orderBook).setBilateral(id, true, false);
			}
            
            if (fetchBilateral(orderBook, id)) {
                refundOrder(
					orderBook,
					clientLedger,
					providerLedger,
					id,
					client,
					provider
				);
                OrderBook(orderBook).deleteItem(id);
                success = true;
            }
        }
    }
    
    function completeOrder(
        address orderBook,
        address register,
        address clientLedger,
		address providerLedger,
        bytes32 id,
        uint reading
    )
    public
    onlyParties(orderBook, register, id)
    returns (uint cost, bool success)
    {
        require(OrderBook(orderBook).active(id));
        
        bytes32 market = OrderBook(orderBook).markets(id);
        address client = OrderBook(orderBook).clients(id);
        address provider = MarketRegister(register).provider(market);

        if (msg.sender == client) {
			OrderBook(orderBook).setGivenReadings(id, true, true);
			OrderBook(orderBook).setReadings(id, reading, true);
		}
		if (msg.sender == provider) {
			OrderBook(orderBook).setGivenReadings(id, true, false);
			OrderBook(orderBook).setReadings(id, reading, false);
		}
        
        if (fetchGiven(orderBook, id)) {
            (cost, success) = computeCost(
				orderBook,
				id,
				MarketRegister(register).isMetered()
			);
            if (success) {
                fillOrder(
					orderBook,
					clientLedger,
					providerLedger,
					id,
					client,
					provider,
					cost
				);
                OrderBook(orderBook).deleteItem(id);
            }
        }
        
    }
    
    function computeCost(
        address orderBook,
        bytes32 id,
        bool isMetered
    )
    private
    returns (uint cost, bool success)
    {
        uint clientReading;
        uint providerReading;
        
        (clientReading, providerReading) = OrderBook(orderBook).readings(id);
        
        if (!isMetered) {
            cost = OrderBook(orderBook).fee(id);
            success = (clientReading == providerReading);
        } else {
            uint tolerance = ServiceOrderBook(orderBook).tolerance(id);
            uint price = OrderBook(orderBook).price(id);
            if (MathLib.dist(clientReading, providerReading) <= tolerance) {

                uint avg = MathLib.average(clientReading, providerReading);
                
                cost = avg*price;
                if (price != 0 && avg > cost/price) {
                    cost = uint(-1);
                }
                success = true;
            } else {
                cost = 0;
                success = false;
            }
        }
    }
    
    function fillOrder(
        address orderBook,
        address clientLedger,
		address providerLedger,
        bytes32 id,
        address client,
        address provider,
        uint amount
    )
    private
    {
        uint stake = OrderBook(orderBook).stake(id);
        uint fee = OrderBook(orderBook).fee(id);
        uint cost = (amount <= fee)? amount : fee;
        
        Ledger(clientLedger).removeLocked(client, stake);
        Ledger(clientLedger).removeGains(client, fee);
        Ledger(clientLedger).addPending(client, stake - cost);
            
        Ledger(providerLedger).removeLocked(provider, stake);
        Ledger(providerLedger).removeGains(provider, 2*fee);
        Ledger(providerLedger).addPending(provider, stake + cost);
    }
    
    function payFee(
        address orderBook,
        address clientLedger,
		address providerLedger,
        bytes32 id,
        address client,
        address provider,
        bool toClient
    )
    private
    {
        uint stake = OrderBook(orderBook).stake(id);
        uint fee = OrderBook(orderBook).fee(id);
        
        Ledger(clientLedger).removeLocked(client, stake);
        Ledger(clientLedger).removeGains(client, fee);
        Ledger(clientLedger).addPending(client, (toClient)?(stake + fee):(stake - fee));
            
        Ledger(providerLedger).removeLocked(provider, stake);
        Ledger(providerLedger).removeGains(provider, 2*fee);
        Ledger(providerLedger).addPending(provider, (toClient)?(stake - fee):(stake + fee));
    }
    
    function refundOrder(
        address orderBook,
        address clientLedger,
		address providerLedger,
        bytes32 id,
        address client,
        address provider
    )
    private
    {
        uint stake = OrderBook(orderBook).stake(id);
        uint fee = OrderBook(orderBook).fee(id);
        
        Ledger(clientLedger).removeLocked(client, stake);
        Ledger(clientLedger).removeGains(client, fee);
        Ledger(clientLedger).addPending(client, stake);
        
        Ledger(providerLedger).removeLocked(provider, stake);
        Ledger(providerLedger).removeGains(provider, 2*fee);
        Ledger(providerLedger).addPending(provider, stake);
        
    }
    
    function createOrder(
        address orderBook,
        bytes32 id,
        bytes32 market,
        address client,
        uint price,
        uint amount,
		uint stakeOffer
    )
    private
    {
        OrderBook(orderBook).setExists(id, true);
        OrderBook(orderBook).setMarket(id, market);
        OrderBook(orderBook).setClient(id, client);
        OrderBook(orderBook).setPrice(id, price);
        OrderBook(orderBook).setStake(id, stakeOffer);
        OrderBook(orderBook).setAmount(id, amount);
    }
	
	function fetchConfirm(address orderBook, bytes32 id)
    constant
    public
    returns (bool isConfirmed)
    {
        bool clientConfirm;
        bool providerConfirm;
        
        (clientConfirm, providerConfirm) = OrderBook(orderBook).confirmations(id);
        
        return (clientConfirm && providerConfirm);
    }
    
    function fetchBilateral(address orderBook, bytes32 id)
    constant
    public
    returns (bool isConfirmed)
    {
        bool clientConfirm;
        bool providerConfirm;
        
        (clientConfirm, providerConfirm) = OrderBook(orderBook).bilateral_cancel(id);
        
        return (clientConfirm && providerConfirm);
    }
    
    function fetchGiven(address orderBook, bytes32 id)
    constant
    public
    returns (bool isConfirmed)
    {
        bool clientConfirm;
        bool providerConfirm;
        
        (clientConfirm, providerConfirm) = OrderBook(orderBook).givenReadings(id);
        
        return (clientConfirm && providerConfirm);
    }
}

library MathLib {
	
	function dist(uint x, uint y) constant public returns (uint){
		return (x>=y)?(x-y):(y-x);
	}
	
	function average(uint x, uint y) constant public returns (uint) {
		return (x>>1) + (y>>1) + (x & y & 1);
	}
}
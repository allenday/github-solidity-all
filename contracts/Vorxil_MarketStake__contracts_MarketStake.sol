pragma solidity ^0.4.11;

import "./Owned.sol";
import "./LedgerLib.sol";
import "./MarketLib.sol";
import "./OrderBookLib.sol";

/**
 * MarketStake - User Interface contract
 * Users connect to the contract through here (e.g. via Geth or a Web3 UI).
 * This contract holds the deposited funds, and the ledger keeps track of it.
 * Providers create markets for their goods on the market register.
 * Goods can be either metered or non-metered, though currently only one
 * is supported per contract.
 * Users create orders on goods and both the client and provider lock
 * part of their deposited funds away as a stake to ensure cooperation.
 */
contract MarketStake is Upgradeable{
    
    address public clientLedger;
	address public providerLedger;
    address public register;
    address public orderBook;
    
    function MarketStake(
        address _clientLedger,
		address _providerLedger,
        address _register,
        address _orderBook
    )
    Upgradeable()
    {
		require(
			MarketRegister(_register).isMetered() == 
			OrderBook(_orderBook).isMetered()
		);
        clientLedger = _clientLedger;
		providerLedger = _providerLedger;
        register = _register;
        orderBook = _orderBook;
    }
    
	/**
	 * Market events
	 */
	 
    event LogNewMarket(bytes32 id);
    event LogMarketShutdown(bytes32 id);
    
    event LogMarketPriceChanged(bytes32 id, uint oldPrice, uint newPrice);
    event LogMarketMinStakeChanged(bytes32 id, uint oldMinimum, uint newMinimum);
    event LogMarketStakeRateChanged(bytes32 id, uint oldRate, uint newRate);
	event LogMarketToleranceChanged(bytes32 id, uint oldTolerance, uint newTolerance);
    
	/**
	 * Order events
	 */
	
    event LogNewOrder(bytes32 marketID, bytes32 orderID, uint price, uint amount, uint stake);
    event LogOrderConfirmed(bytes32 orderID, address confirmer);
    event LogOrderActivated(bytes32 orderID);
    event LogOrderNewReading(bytes32 orderID, uint reading);
    event LogOrderFilled(bytes32 orderID, uint cost);
    event LogOrderCancelled(bytes32 orderID, address canceller);
    event LogOrderBilateralSought(bytes32 orderID, address seeker);
    event LogOrderBilateralCancel(bytes32 orderID);
    
	/**
	 * Ledger events
	 */
	
    event LogDepositClient(address depositor, uint deposit);
    event LogWithdrawClient(address withdrawer);
	event LogDepositProvider(address depositor, uint deposit);
    event LogWithdrawProvider(address withdrawer);
	
	/**
	 * addMarket - add a market to the register
	 * @param price - price in Wei/[smallest measurable unit]
	 * @param minStake - smallest valid absolute stake
	 * @param stakeRate - smallest valid relative stake
	 * @param tolerance - greatest tolerable distance between two readings in [smallest measurable unit] 
	 * 		(Non-metered goods are always exact)
	 * @return id - hash id of the new market
	 * Event: LogNewMarket(id)
	 */
	function addMarket(
		uint price,
		uint minStake,
		uint stakeRate,
		uint tolerance
	)
	external
	returns (bytes32 id)
	{
        id = MarketLib.addMarket(register, price, minStake, stakeRate, tolerance);
        LogNewMarket(id);
    }
    
	/**
	 * changePrice - change the price on the market, does not affect created orders
	 * Provider only
	 * @param id - market hash id
	 * @param newPrice - the new price of the market goods.
	 * Event: LogMarketPriceChanged(id, oldPrice, newPrice)
	 */
    function changePrice(bytes32 id, uint newPrice) external {
		uint oldPrice = MarketRegister(register).price(id);
        MarketLib.changePrice(register, id, newPrice);
        LogMarketPriceChanged(id, oldPrice, newPrice);
	}
    
	/**
	 * changeMinStake - change the minimum valid stake, does not affect created orders
	 * Provider only
	 * @param id - market hash id
	 * @param newMinimum - the new minimum valid stake of the market goods.
	 * Event: LogMarketMinStakeChanged(id, oldMinimum, newMinimum)
	 */
    function changeMinStake(bytes32 id, uint newMinimum) external {
        uint oldMinimum = MarketRegister(register).minStake(id);
        MarketLib.changeMinStake(register, id, newMinimum);
        LogMarketMinStakeChanged(id, oldMinimum, newMinimum);
    }
    
	/**
	 * changeStakeRate - change the minimum relative valid stake, does not affect created orders
	 * Provider only
	 * @param id - market hash id
	 * @param newRate - the new minimum relative valid stake of the market goods.
	 * Event: LogMarketStakeRateChanged(id, oldRate, newRate)
	 */
    function changeStakeRate(bytes32 id, uint newRate) external {
        uint oldRate = MarketRegister(register).stakeRate(id);
        MarketLib.changeStakeRate(register, id, newRate);
        LogMarketStakeRateChanged(id, oldRate, newRate);
    }
	
	/**
	 * changeTolerance - change the tolerance, does not affect created orders
	 * Provider only
	 * @param id - market hash id
	 * @param newTolerance - the new tolerance
	 * Event: LogMarketToleranceChanged(id, oldTolerance, newTolerance)
	 */
	function changeTolerance(bytes32 id, uint newTolerance) external {
        uint oldTolerance = ServiceRegister(register).tolerance(id);
        MarketLib.changeTolerance(register, id, newTolerance);
        LogMarketToleranceChanged(id, oldTolerance, newTolerance);
    }
    
	/**
	 * shutdownMarket - Permanently shutdown the market, breaching the contract for any active orders.
	 * Provider only
	 * @param id - market hash id
	 * Event: LogMarketShutdown(id)
	 */
    function shutdownMarket(bytes32 id) external {
        MarketLib.shutdownMarket(register, id);
        LogMarketShutdown(id);
    }
    
	/**
	 * order - create an order for a market good at current price
	 * @param id - market hash id
	 * @param amount - number of [smallest measurable units] to order
	 * @param stakeOffer - stake that the sender is willing to offer in Wei
	 * @return orderID - order hash id
	 * Event: LogNewOrder(id, orderID, price, amount, stake)
	 */
    function order(bytes32 id, uint amount, uint stakeOffer) external returns (bytes32 orderID) {
        orderID = OrderBookLib.makeOrder(
            orderBook,
            register,
            id,
            amount,
			stakeOffer
        );
        LogNewOrder(
            id,
            orderID,
            OrderBook(orderBook).price(orderID),
            amount,
			stakeOffer
        );
    }
    
	/**
	 * confirm - sender confirms the existing order
	 * 		Both the client and the provider needs to confirm to activate
	 * Client and provider only
	 * Existing orders only
	 * @param id - order hash id
	 * Event: LogOrderConfirmed(id, confirmer)
	 * Event: LogOrderActivated(id)
	 */
    function confirm(bytes32 id) external {
        bool success = OrderBookLib.confirmOrder(
			orderBook,
			register,
			clientLedger,
			providerLedger,
			id
		);
        LogOrderConfirmed(id, msg.sender);
        if (success) {
            LogOrderActivated(id);
        }
    }
    
	/**
	 * completeOrder - sender provides a reading to the order.
	 *		If the client's and provider's readings match, the order is filled
	 * Client and provider only
	 * Active orders only
	 * @param id - order hash id
	 * @param reading - reading in [smallest measurable unit]
	 * Event: LogOrderNewReading(id, reading)
	 * Event: LogOrderFilled(id, cost)
	 */
    function completeOrder(bytes32 id, uint reading) external {
        uint cost;
        bool success;
        (cost, success) = OrderBookLib.completeOrder(
            orderBook,
            register,
            clientLedger,
			providerLedger,
            id,
            reading
        );
        LogOrderNewReading(id, reading);
        if (success) {
            LogOrderFilled(id, cost);
        }
    }
    
	/**
	 * cancelOrder - unilaterally cancel the order, breaching the contract
	 *		If the order is active, the contract breacher pays a fee equal to amount*price
	 * Client and provider only
	 * @param id - order hash id
	 * Event: LogOrderCancelled(id, canceller)
	 */
    function cancelOrder(bytes32 id) external {
		bytes32 market = OrderBook(orderBook).markets(id);
        OrderBookLib.cancelOrder(
			orderBook,
			register,
			clientLedger,
			providerLedger,
			id
		);        
        LogOrderCancelled(
            id, 
            (MarketRegister(register).active(market)) ? msg.sender :
			MarketRegister(register).provider(market)
        );
    }
    
	/**
	 * bilateralCancelOrder - bilaterally cancel the order
	 * 		Both the client and the provider must agree to cancel the order
	 *		No fee is paid
	 * Client and provider only
	 * Active orders only
	 * @param id - order hash id
	 * Event: LogOrderBilateralSought(id, seeker)
	 * Event: LogOrderBilateralCancel(id)
	 */
    function bilateralCancelOrder(bytes32 id) external {
        bool success = OrderBookLib.bilateralCancel(
			orderBook,
			register,
			clientLedger,
			providerLedger,
			id
		);
        LogOrderBilateralSought(id, msg.sender);
        if (success) {
            LogOrderBilateralCancel(id);
        }
    }
    
	/**
	 * Deposit ether onto the client ledger
	 * Payable
	 */
    function depositClient() payable external {
        LedgerLib.deposit(clientLedger, msg.value);
        LogDepositClient(msg.sender, msg.value);
    }
    
	/**
	 * Withdraw all pending ether from the client ledger
	 */
    function withdrawClient() external {
        LedgerLib.withdraw(clientLedger);
        LogWithdrawClient(msg.sender);
    }    
	
	/**
	 * Deposit ether onto the provider ledger
	 * Payable
	 */
	function depositProvider() payable external {
        LedgerLib.deposit(providerLedger, msg.value);
        LogDepositProvider(msg.sender, msg.value);
    }
    
	/**
	 * Withdraw all pending ether from the provider ledger
	 */
    function withdrawProvider() external {
        LedgerLib.withdraw(providerLedger);
        LogWithdrawProvider(msg.sender);
    }    
	
	function upgradeDuties() private {
		Allowable(clientLedger).allow(upgradeTo);
		Allowable(providerLedger).allow(upgradeTo);
		Allowable(register).allow(upgradeTo);
		Allowable(orderBook).allow(upgradeTo);
		Allowable(clientLedger).disallow(this);
		Allowable(providerLedger).disallow(this);
		Allowable(register).disallow(this);
		Allowable(orderBook).disallow(this);
		Allowable(clientLedger).transferOwnership(upgradeTo);
		Allowable(providerLedger).transferOwnership(upgradeTo);
		Allowable(register).transferOwnership(upgradeTo);
		Allowable(orderBook).transferOwnership(upgradeTo);
	}
}
import "Owned";

contract PredictionMarket is Owned
{
	struct Order
	{
		address seller;
		address buyer;
		uint odds;				// in %
		uint sellerQuantity;	// in wei
		uint buyerQuantity;		// in wei
	}

	Order[] public orders;
	uint lastTradedOdds = 50;
	uint endTime;

	function PredictionMarket(uint _endTime)
	{
		endTime = _endTime;
	}

	function ordersLength() constant
		returns(uint result)
	{
		return orders.length;
	}

	function sellOrder(uint odds)
	{
		if(now >= endTime || odds < 1 || odds > 99)
		{
			// must be valid time
			// odds must be from 1-99%
			msg.sender.send(msg.value);
			return;
		}

		var seller = msg.sender;
		var sellerQuantity = msg.value;
		
		while(sellerQuantity > 0)
		{
			var maxOddsFound = false;
			var maxOddsIndex = 0;
			var maxOdds = odds - 1;

			for(var i = 0; i < orders.length; i++)
			{
				var o = orders[i];

				if(o.seller == 0 && o.odds > maxOdds)
				{
					maxOddsFound = true;
					maxOddsIndex = i;
					maxOdds = o.odds;
				}
			}

			if(maxOddsFound)
			{
				lastTradedOdds = maxOdds;
				var mo = orders[maxOddsIndex];

				if(sellerQuantity >= mo.sellerQuantity)
				{
					// maxOdds only partially fills order

					mo.seller = seller;
					sellerQuantity -= mo.sellerQuantity;
				}
				else
				{
					// maxOdds completely fills order

					var mBuyerQuantity = sellerQuantity * 100 / (100 - mo.odds) - sellerQuantity;

					if(mBuyerQuantity < mo.buyerQuantity)
					{
						// create a new order that represents the completed trade
						var completedOrder = Order(seller, mo.buyer, mo.odds, sellerQuantity, mBuyerQuantity);
						orders.push(completedOrder);

						// adjust maxOdds in place to preserve the order's priority
						mo.buyerQuantity -= mBuyerQuantity;
						mo.sellerQuantity -= sellerQuantity;

						sellerQuantity = 0;
					}
					else
					{
						// everything must just be off by a rounding error, so just call it even
						// I'm not sure that it is even possible to get here

						mo.seller = seller;
						sellerQuantity = 0;
					}
				}
			}
			else
			{
				// no suitable existing order found, so create a new one

				var buyerQuantity = sellerQuantity * 100 / (100 - odds) - sellerQuantity;

				var order = Order(seller, 0, odds, sellerQuantity, buyerQuantity);
				orders.push(order);

				sellerQuantity = 0;
			}
		}
	}

	function buyOrder(uint odds)
	{
		if(now >= endTime || odds < 1 || odds > 99)
		{
			// must be valid time
			// odds must be from 1-99%
			msg.sender.send(msg.value);
			return;
		}

		var buyer = msg.sender;
		var buyerQuantity = msg.value;
		
		while(buyerQuantity > 0)
		{
			var minOddsFound = false;
			var minOddsIndex = 0;
			var minOdds = odds + 1;

			for(var i = 0; i < orders.length; i++)
			{
				var o = orders[i];

				if(o.buyer == 0 && o.odds < minOdds)
				{
					minOddsFound = true;
					minOddsIndex = i;
					minOdds = o.odds;
				}
			}

			if(minOddsFound)
			{
				lastTradedOdds = minOdds;
				var mo = orders[minOddsIndex];

				if(buyerQuantity >= mo.buyerQuantity)
				{
					// minOdds only partially fills order

					mo.buyer = buyer;
					buyerQuantity -= mo.buyerQuantity;
				}
				else
				{
					// minOdds completely fills order

					var mSellerQuantity = buyerQuantity * 100 / mo.odds - buyerQuantity;

					if(mSellerQuantity < mo.sellerQuantity)
					{
						// create a new order that represents the completed trade
						var completedOrder = Order(mo.seller, buyer, mo.odds, mSellerQuantity, buyerQuantity);
						orders.push(completedOrder);

						// adjust minOdds in place to preserve the order's priority
						mo.buyerQuantity -= buyerQuantity;
						mo.sellerQuantity -= mSellerQuantity;

						buyerQuantity = 0;
					}
					else
					{
						// everything must just be off by a rounding error, so just call it even
						// I'm not sure that it is even possible to get here

						mo.buyer = buyer;
						buyerQuantity = 0;
					}
				}
			}
			else
			{
				// no suitable existing order found, so create a new one

				var sellerQuantity = buyerQuantity * 100 / odds - buyerQuantity;

				var order = Order(0, buyer, odds, sellerQuantity, buyerQuantity);
				orders.push(order);

				buyerQuantity = 0;
			}
		}
	}

	function cancelOrder(uint odds, uint quantity)
	{
		if(now >= endTime)
		{
			// must be valid time
		}

		var deleting = false;

		for(var i = 0; i < orders.length; i++)
		{
			var o = orders[i];

			if(!deleting)
			{
				if(o.odds == odds)
				{
					if(o.buyer == msg.sender && o.seller == 0)
					{
						o.buyerQuantity -= quantity;

						if(o.buyerQuantity <= 0)
						{
							deleting = true;
						}
						else
						{
							o.sellerQuantity = o.buyerQuantity * 100 / odds - o.buyerQuantity;
						}
					}
					else if(o.seller == msg.sender && o.buyer == 0)
					{
						o.sellerQuantity -= quantity;

						if(o.sellerQuantity <= 0)
						{
							deleting = true;
						}
						else
						{
							o.buyerQuantity = o.sellerQuantity * 100 / (100 - odds) - o.sellerQuantity;
						}
					}
				}
			}
			else
			{
				orders[i - 1] = o;
			}
		}

		if(deleting)
		{
			orders.length--;
		}
	}

	function cancelIncompleteOrders() onlyowner
	{
		if(now >= endTime)
		{
			for(var i = 0; i < orders.length; i++)
			{
				var o = orders[i];

				if(o.buyer == 0)
				{
					o.seller.send(o.sellerQuantity);
				}

				if(o.seller == 0)
				{
					o.buyer.send(o.buyerQuantity);
				}
			}
		}
	}

	function evaluateOdds() constant
		returns(uint)
	{
		return lastTradedOdds;
	}

	function awardBuyers() onlyowner
	{
		for(var i = 0; i < orders.length; i++)
		{
			var o = orders[i];

			if(o.buyer != 0 && o.seller != 0)
			{
				o.buyer.send(o.buyerQuantity + o.sellerQuantity);
			}
			else if(o.buyer != 0)
			{
				o.buyer.send(o.buyerQuantity);
			}
			else if(o.seller != 0)
			{
				o.seller.send(o.sellerQuantity);
			}
		}

		suicide(owner);
	}

	function awardSellers() onlyowner
	{
		for(var i = 0; i < orders.length; i++)
		{
			var o = orders[i];

			if(o.buyer != 0 && o.seller != 0)
			{
				o.seller.send(o.buyerQuantity + o.sellerQuantity);
			}
			else if(o.buyer != 0)
			{
				o.buyer.send(o.buyerQuantity);
			}
			else if(o.seller != 0)
			{
				o.seller.send(o.sellerQuantity);
			}
		}

		suicide(owner);
	}

	function revert() onlyowner
	{
		for(var i = 0; i < orders.length; i++)
		{
			var o = orders[i];

			if(o.buyer != 0)
			{
				o.buyer.send(o.buyerQuantity);
			}

			if(o.seller != 0)
			{
				o.seller.send(o.sellerQuantity);
			}
		}

		suicide(owner);
	}
}

pragma solidity ^0.4.2;

contract shops {
    // @title shops
    // @author Rogelio SEGOVIA
	
	address public sysAdmin;   
	uint nrGoods;
	uint nrSells;

// @notice at creating the contract we declare the general variables
function shops () {
			// @param the initial sysAdmin is the address from which the
			// contract is created
			sysAdmin = msg.sender;
		    nrGoods = 0;
		    nrSells = 0;
    }

	event Sell (uint _sellNumber, address indexed _buyer, address indexed _seller, uint _good, uint _price, uint _TimeStamp);
	
		struct Goods {
			address seller;
			string cathegory;
			string narrative;
			string goodImageLink;
			uint unitPrice; 
			uint nrSells;
			int userSatisfaction;
			bool onOffer;
		}
		
		mapping(uint => Goods) good; 
		
		function offer (string _cathegory, string _narrative, string _goodImageLink, uint _unitPrice) {
			nrGoods ++;
			uint goodNumber = nrGoods;
			good[goodNumber].seller = msg.sender;
			good[goodNumber].cathegory = _cathegory;
			good[goodNumber].narrative = _narrative;
			good[goodNumber].goodImageLink = _goodImageLink;
			good[goodNumber].unitPrice = _unitPrice;
			good[goodNumber].nrSells = 0;
			good[goodNumber].userSatisfaction = 0;
			good[goodNumber].onOffer = true;
		}
		
		function getGood (uint _goodNumber) constant returns (address, string, string, string, uint, bool) {
			return (good[_goodNumber].seller, good[_goodNumber].cathegory, good[_goodNumber].narrative, good[_goodNumber].goodImageLink, good[_goodNumber].unitPrice, good[_goodNumber].onOffer);
		}
		
		function offerOn (uint _goodNumber) {
			if (good[_goodNumber].seller == msg.sender) {
				good[_goodNumber].onOffer = true;
			}
		}

		function offerOff (uint _goodNumber) {
			if (good[_goodNumber].seller == msg.sender) {
				good[_goodNumber].onOffer = false;
			}
		}
		
		
		
	
		struct Sells {
		uint good;
		uint units;
		address buyer;
		uint price;
		uint sellDateTime;
		bool bill;
		bool received;
	    }

	mapping(uint => Sells) sell;    

	function buy (uint _good, uint _units) {
	    nrSells ++;
		uint sellNumber = nrSells;
		sell[sellNumber].good = _good;
		sell[sellNumber].units = _units;
		sell[sellNumber].buyer = msg.sender;
		sell[sellNumber].price = good[_good].unitPrice * _units;
		sell[sellNumber].sellDateTime = now;
		sell[sellNumber].bill = false;	
		sell[sellNumber].received = false;
		good[_good].nrSells ++;
		address _seller = good[_good].seller;
		Sell (nrSells, msg.sender, _seller, _good, sell[sellNumber].price, now);
	}
	
	function sendBill (uint _sellNumber) {
	    uint _good = sell[_sellNumber].good;
	    address _seller = good[_good].seller;
		if (_seller == msg.sender) {
			sell[_sellNumber].bill = true;	
			}    	
	}	
	
	function signReceipt (uint _sellNumber, int _userSatisfaction) {
		if (sell[_sellNumber].buyer == msg.sender) {
		    uint _good = sell[_sellNumber].good;
	        address _seller = good[_good].seller;
			good[_good].userSatisfaction += _userSatisfaction;
		sell[_sellNumber].received = true;
			}    	
	}	
	
	function getsell (uint _sellNumber) constant returns (uint, uint, uint, uint, bool, bool) {
	    uint _good = sell[_sellNumber].good;
	    address _seller = good[_good].seller;
		return (_good, sell[_sellNumber].units, sell[_sellNumber].price, sell[_sellNumber].sellDateTime, sell[_sellNumber].bill, sell[_sellNumber].received);
	}
	
	function getSellAgents (uint _sellNumber) constant returns (uint,address, address) {
	    uint _good = sell[_sellNumber].good;
	    address _seller = good[_good].seller;
		return (_good, _seller, sell[_sellNumber].buyer);
	}
		
}

pragma solidity ^0.4.2;

contract PriceCalculator {

	function getPrice(string manufacturer, string productType, uint price) constant returns(uint) {
		return price * 5 / 100;
	}
}

contract Epam {

	struct Product {
		address retailer;
		string manufacturer;
		string productType;
		address customer;
		string warrantyId;
		uint warrantyEndDate;
		uint price;
	}

	struct Claim {
		address claimant;
		uint amount;
		string serial;
		uint date;
		string claimType;
	}

	struct Request {
		string serial;
		uint date;
	}

	address owner;
	mapping(string => Product) products;
	mapping(uint => Claim) claims;
	mapping(uint => Request) requests;
	uint claimCount;
	uint requestCount;

	PriceCalculator calculator;

	modifier ownerOnly {
		if(msg.sender != owner) {
			throw;
		}
		_;
	}

	modifier noWarranty(string serial) {
		if(isWarrantyValid(serial)) {
			throw;
		}
		_;
	}

	function Epam() {
		owner = msg.sender;
	}

	function updateCalculator(address contractAddress) ownerOnly {
		calculator = PriceCalculator(contractAddress);
	}

	function requestWarranty(string serial, address customer, uint endDate, uint price) noWarranty(serial) {
		Product product = products[serial];
		product.retailer = msg.sender;
		product.customer = customer;
		product.warrantyEndDate = endDate;
		product.price = price;

		products[serial] = product;

		Request request = requests[requestCount];
		request.date = now;
		request.serial = serial;
		requestCount++;
	}

	function claimWarranty(string serial, uint amount, string claimType) {
		Claim claim = claims[claimCount];
		claim.claimant = msg.sender;
		claim.amount = amount;
		claim.serial = serial;
		claim.date = now;
		claim.claimType = claimType;
		claimCount++;
	}

	function isWarrantyValid(string serial) constant returns (bool) {
		return products[serial].warrantyEndDate > now;
	}

	function getEndDate(string serial) constant returns (uint) {
		return products[serial].warrantyEndDate;
	}

	function getCustomer(string serial) constant returns (address) {
		return products[serial].customer;
	}

	function getClaimCount() constant returns (uint) {
		return claimCount;
	}

	function getClaim(uint id) constant returns (address, uint, string, uint, string) {
		return (claims[id].claimant, claims[id].amount, claims[id].serial, claims[id].date, claims[id].claimType);
	}

	function getRequestCount() constant returns (uint) {
		return requestCount;
	}

	function getProduct(string serial) constant returns(address , string , string , address, string, uint, uint) {
		Product product = products[serial];
		return (product.retailer, product.manufacturer, product.productType, product.customer, product.warrantyId, product.warrantyEndDate, product.price);
	}

	function getRequest(uint id) constant returns (uint, string, string, string, address, string, uint, uint) {
		Product product = products[requests[id].serial];
		return (requests[id].date, requests[id].serial, product.manufacturer, product.productType, product.retailer, product.warrantyId, product.warrantyEndDate, product.price);
	}

}
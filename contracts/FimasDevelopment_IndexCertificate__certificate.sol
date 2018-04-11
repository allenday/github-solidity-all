contract IndexCertificate {
    
	
	string UnderlyingName;  //Underlying Index Reference
	bool BuyerLong; 	    //Long or short position of the Buyer
    uint IndexStrike;       //Strike Price
	uint PayAmount;         //Reward, if Strike is reached. Could also be a formula, etc.
	
	uint ContractPremium;   //Premium to be paid by the buyer
	uint IndexValue;        //Actual index value 

	address Issuer;         //address of the issuer
	address Buyer;          //address of the buyer
	
	// Other parameters skipped for ease of use (expiration date, quantity, etc)
	
	// ContractPrice should be separate from the rest (constant and immutable contract vs variable contract premium. Or other values declared private)
    function initiateCertificate(bool bLong, string uName, uint iStrike, uint cPremium, uint iValue, uint pAmount) {
        Issuer = msg.sender;
		BuyerLong = bLong;
		UnderlyingName = uName;
		IndexStrike = iStrike;
		PayAmount = pAmount;
		ContractPremium = cPremium;
		IndexValue = iValue;
	}
    
	
	//the Buyer enters into the contract here by paying the Contract Premium.
	//the Issuer gets the Premium immediately.
    function buyCertificate(uint cPremium) {
		if (ContractPremium == cPremium) {
			Buyer = msg.sender;
			Issuer.send(ContractPremium);
        }
	}	
	
	//only the issuer can update the contract premium and Index Value. Usually at the same time.
	//Setting the index value could be done by a trusted neutral party as well. Simply using the address of the neutral third party in a separate funciton.
    function updatePrice(uint cPremium, uint iValue) {
        if (msg.sender == Issuer) {
			ContractPremium = cPremium;
			IndexValue = iValue;

			if (BuyerLong) {
				if (IndexValue > IndexStrike) {
					Buyer.send(PayAmount);
				}

			else if (IndexValue < IndexStrike) {
					Buyer.send(PayAmount);
				}
			}
		}
	}
}

// WeiLend System v0.2
// Start, lend, payout and return interest yield to funders
// @creator of the original WeiFund code:
// Nick Dodson <thenickdodson@gmail.com>
// @forked to implement the WeiLend by:
// M. Terzi <ma.terzi@tiscali.it> ===> http://github.com/terzim
// If goal is not reached and campaign is expired, contributers can get their donation refunded individually
// If goal is reached by alloted time, contributions can still be made
// After a grace period, the beneficiary returns funds to the funders in installments at a given interest rate

contract WeiLendConfig 
{ 
    function onNewLoan(uint lid, address addr, uint goal){}
    function onContribute(uint lid, address addr, uint amount){} 
    function onRefund(uint lid, address addr, uint amount){} 
    function onPayout(uint lid, uint amount){}
    function onpayInstallment(uint lid, address addr, uint balance){}
}

/// @title WeiLend - A Decentralized P2P Lending Platform
/// @author Massimiliano Terzi <ma.terzi@tiscali.it>
contract WeiLend 
{
    // @notice User: This object stores the loan operator data
    // @dev This object stores all pertinant loan operator data, such as how many loans the operator has started, and the loan ID's of all the loans they have or are operating
    struct User
    {
        uint numLoans;
        mapping(uint => uint) loans;
    }
    
    // @notice Funder; This object helps store the pertinant contributer data.
    // @dev This object stores the contributer data, such as the contributer address, and amount.
    struct Funder 
    {
        address from;
        address addr;
        uint amount;
    }
    
    // @notice Loan; The crowdlending loan object
    // @dev This object stores all the pertinant loan data, such as: the name, beneificiary, fundingGoal, and the funder data, interest yield, tenor, etc... 
    struct Loan 
    {
        bytes32 operationName;
        bytes32 website;
        bytes32 video;
        address owner;
        address beneficiary;
        address config; 
        uint timelimit;
        uint fundingGoal;
        uint amount;
        uint balance;
        uint category;
        uint status;
        uint numFunders;
        uint interestRateM; // monthly         
        uint gracePeriod;
        uint tenorM; // monthly
        uint installment; // monthly
        mapping (uint => Funder) funders;
        mapping (address => uint) toFunder;
    }

    /// @notice numLoans; The total number of crowdlending campaigns started on WeiLend
    /// @dev This is the uint store that contains the number of the total amount of all crowdlending campaigns started on WeiLend. This is also used to generate loan ID numbers.  
    uint public numLoans;
    
    /// @notice Loans (the loan ID); Get the loan data at the specified loan ID
    /// @dev This data store maps loan ID's to stored Loan objects. With this method you can access any crowdlending campaign started on WeiLend.
    mapping (uint => Loan) public loans;
    
    /// @notice Users (the user address); Get the number of loans a user has started
    /// @dev This will return a user object that contains the number of loans a user has started. Use the userLoans method to the ID's to the crowdlending campaigns that they have started.
    mapping (address => User) public users;
    
	// The WeiLend Events
    event onNewLoan(address indexed _from, uint indexed _lid);
    event onContribute(address indexed _from, uint indexed _lid, uint _value);
    event onPayout(address indexed _from, uint indexed _lid, uint _value);
    event onRefund(address indexed _from, uint indexed _lid, uint _value);
    event onpayInstallment(address indexed _from, uint indexed _lid, uint _value);

     modifier hasValue { if(msg.value > 0) _ }

    /// @notice New Loan; create a new crowdlending campaign
    /// @dev This method starts a new crowdlending campaign and fires the onNewLoan event when transacted.
    /// @param _operationName The loan name
    /// @param _website The website of the crowdlending campaign
    /// @param _video The compressed video url (e.g. yt JFdi289d)
    /// @param _beneficiary The address of the beneficiary for this loan
    /// @param _goal The funding goal of the loan. If this goal is not met by the timelimit, all ether will be refunded to the respective contributers
    /// @param _timelimit_m The timelimit for the loan (in months)
    /// @param _interest_rate The interest rate for this lending operation 
    /// @param _grace_period_m The grace period for this lending operation, during which the borrower will only pay interest and not principal repayments
    /// @param _category The category ID for the crowdlending campaign (e.g. 2: Technology)
    /// @param _config
 	/// @param _tenor_a The total number of years this loan will run for. After the tenor expires, all the principal repayments must be satisfied
 	function newLoan(bytes32 _operationName, bytes32 _website, bytes32 _video, address _beneficiary, uint _goal, uint _timelimit_m, uint _category, uint _interest_rate, uint _grace_period_m, uint _tenor_a, address _config)
    {
    
        // if the goal (one of the parameters of the function assigned by the person 
        // who runs the function is greater than zero [not sure this shoudl stay here though]
        // and the timelimit is greater than now (that is, the campaign has not expired] do....  
        
        if(_goal > 0 ){
            
            // initialize a new variable called lid, which is a counter for the numLoans (defined earlier as a public integer variable)
            uint lid = numLoans++; // campaignID is return variable
            // creates a loan called l which will corrispond the [position lid in the mapping of all loans]
            Loan l = loans[lid];  // assigns reference
            l.operationName = _operationName; // vanity
            l.website = _website; // vanity
            l.video = _video; // vanity
            // again assign to the loan l the beneficiary defined by the argument of the function
            l.beneficiary = _beneficiary;
            // again assign to the loan l the fundingGoal defined by the argument of the function
            l.fundingGoal = _goal;
            l.owner = msg.sender;
            // again assign to the loan l the timelimit defined by the argument of the function
            l.timelimit = block.timestamp + (_timelimit_m * 43200);
            // again assign to the loan l the category defined by the argument of the function
            l.category = _category;
            // again assign to the loan l the interest rate defined by the argument of the function
            l.interestRateM = _interest_rate / 12;
            // again assign to the loan l the grace period defined by the argument of the function
            l.gracePeriod = _grace_period_m * 43200;
            // again assign to the loan l the tenor defined by the argument of the function (note, tenor meant to be after grace period)
            l.tenorM = _tenor_a * 12;
            l.config = _config;
            // now creates a user called u, which is the sender of the transaction
            User u = users[msg.sender];
            // creates a variable called u_lid, which adds a one to the number of loans the user has made.
            uint u_lid = u.numLoans++;
            u.loans[u_lid] = lid;
            
            // calls the event onNewLoan
            onNewLoan(msg.sender, lid);

            if(l.config != address(0))
                WeiLendConfig(l.config).onNewLoan(lid, msg.sender, _goal);

        }
    }

    /// @notice Contribute (the loan ID); contribute ether to a WeiLend campaign
    /// @dev This method will contribute an amount of ether to the loan at ID _lid. All contribution data will be stored so that the issuance of digital assets can be made out to the contributor address
    /// @param _lid (Loan ID) The ID number of the crowdlending campaign
    /// @param _addr (Contribute As Address) This allows a user to contribute on behalf of another address, if left empty, the from sender address is used as the primary Funder address 
 	function contribute(uint _lid, address _addr) hasValue
    {
        Loan l = loans[_lid]; // Cannot be expired.
        
        // if the raising is not yet terminated
        if(l.timelimit >= block.timestamp) {
            uint fid = l.numFunders++;
            Funder f = l.funders[fid];
            f.from = msg.sender;
            f.addr = _addr;
            f.amount = msg.value;
            //increases the loan amount by the contribution
            l.amount += f.amount;
            //sends a funder id to the funder
            l.toFunder[msg.sender] = fid;
            onContribute(msg.sender, _lid, l.amount);

            if(l.config != address(0))
                WeiLendConfig(l.config).onContribute(_lid, msg.sender, msg.value);

        }
    }

    /// @notice Refund (the loan ID); refund your contribution of a failed or expired crowdlending campaign. 
    /// @dev This method will refund the amount you contributed to a WeiLend campaign, if that loan campaign has failed to meet its funding goal or has expired.
    /// @param _lid (Loan ID) The ID number of the crowdlending campaign to be refunded
 	function refund(uint _lid)
    {
        Loan l = loans[_lid];
        if (block.timestamp > l.timelimit 
        && l.amount < l.fundingGoal && l.amount > 0){
            Funder f = l.funders[l.toFunder[msg.sender]];
            if(f.amount > 0){
            	address recv = f.from;

				if(f.addr != address(0))
					recv = f.addr;

                recv.send(f.amount);
                l.amount -= f.amount;
                onRefund(recv, _lid, f.amount);
                f.amount = 0;
            
                if(l.config != address(0))
                    WeiLendConfig(l.config).onRefund(_lid, recv, f.amount);

            }
        }
    }

    /// @notice Payout (the loan ID); this will payout a successfull crowdlending campaign to the beneficiary address
    /// @dev This method will payout a successfull WeiLend crowdlending campaign to the beneficiary address specified. Any person can trigger the payout by calling this method.
    /// @param _lid (Loan ID) The ID number of the crowdlending campaign
 function payout(uint _lid)
    {
        Loan l = loans[_lid];
        if (l.amount >= l.fundingGoal){
            //calculates the monthly installment amount. Constant installment loan
            l.installment = l.amount * ((l.interestRateM*((1+l.interestRateM)**(l.tenorM)))/(((1+l.interestRateM)**(l.tenorM))-1));            
            l.beneficiary.send(l.amount);
            l.balance = l.amount;
            l.timelimit = l.timelimit + l.gracePeriod;

            onPayout(msg.sender, _lid, l.amount);
            l.amount = 0;            
            l.status = 1;

            if(l.config != address(0))
                WeiLendConfig(l.config).onPayout(_lid, l.amount);

        }
    }

 function payInstallment(uint _lid)
    {
        Loan l = loans[_lid];
        //returns if the borrower is paying a wrong installment amount (error handling)
        if (msg.value != l.installment){
            msg.sender.send(msg.value);
            return;
        }

        //returns if the grace period is not over
        if (block.timestamp < l.timelimit) return;
        //returns if the loan balance is below zero (error handling)
        if (l.balance < 0) return;

        uint i = 0;
        uint n = l.numFunders;
        
        //maybe the while is not needed here. Could use the toFunder functionality?
        //in essence this loops returns to each funder his/her quota of the total installment 
        while(i<n){
            uint entitlement = l.installment*l.funders[i].amount/l.amount;
            l.funders[i].addr.send(entitlement);
            i++; //added counter. Need to check with Ken if needed
        }
  
        //updates the balance of the loan. The installment remains constant throughout the duration of the loan but the balance
        //decreases of the principal amount paid along with the installment. 
        l.balance -= (l.installment -(l.balance*l.interestRateM)); 
        onpayInstallment(msg.sender, _lid, l.balance);

            if(l.config != address(0))
                WeiLendConfig(l.config).onpayInstallment(msg.sender, _lid, l.balance);

    }

    /// @notice User Loans (the address of the user, the user loan ID); get the loan ID of one of the users crowdlending campaigns.
    /// @dev This method will get the loan ID of one of the users crowdlending campaigns, by looking up the loan with a user loan ID. All loan owners and their loans are stored with WeiLend.
    /// @param _addr The address of the loan operator.
    /// @param _u_cid The user loan ID
    /// @return cid The loan ID
    function userLoans(address _addr, uint _u_lid) returns (uint lid)
    {
        User u = users[_addr];
        lid = u.loans[_u_lid];
    }
}

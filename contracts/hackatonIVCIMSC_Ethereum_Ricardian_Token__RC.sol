pragma solidity ^0.4.11;

contract ricardianVoucher {
	/* Generic Voucher Language https:/*tools.ietf.org/html/draft-ietf-trade-voucher-lang-07 */
	/* The Ricardian Financial Instrument Contract http:/*www.systemics.com/docs/ricardo/issuer/contract.html */
	
    /* Owner of this smart contract */
    address public owner;
    
    /* Functions with this modifier can only be executed by the owner */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    /* voucherToken MANAGEMENT */ 
	
	/* Public variables of the voucherToken */	
    string public standard = 'Token 0.1';
    uint public totalSupply;
    string public voucherTokenName;
    uint public decimals;
    string public voucherTokenSymbol;
    string public voucherTokenLogoBzz;  		
    uint public validity_start; 				
    uint public validity_end; 					
    
    /* Initializes voucherToken with initial supply voucherTokens to the creator of the contract */
    function ricardianVoucher(
        ) {
    	owner = msg.sender;
        totalSupply = 1000000000;                        	
        balanceOf[owner] = totalSupply;       	            
        voucherTokenName = "kgCROPS";               
        voucherTokenSymbol = "kC";           
        decimals = 2; 								
        provider[owner].member=true;
        provider[owner].name="KOMPU"; 	
        provider[owner].country="India"; 		
        provider[owner].registration="91-11-26341807"; 	
        provider[owner].Bzz="http://www.nafed-india.com/";
        providerIndex[0]= owner;
    }
    
    /* balanceOf for each account, member or not member */
    mapping(address => uint) balanceOf; 
    
    /* CONTRACT MANAGEMENT */
    
    address public contractBzz; 				
    string[10] merchandises; 						
    string[10] definitions; 						
    string[10] conditions; 
    
    /* write contract terms */
    /* only the owner can write the contract terms */
    /* contract terms can only be written before circulation */
    
    function linkContract (address _contractBzz) onlyOwner { 
    	contractBzz = _contractBzz;
    }
    
    
    function initializeToken (string _voucherTokenLogoBzz, uint _days_start, uint _days_end) {
        voucherTokenLogoBzz = _voucherTokenLogoBzz;
        validity_start = now + _days_start * 1 days;
        validity_end = now + _days_end * 1 days;  
    }
    
    function writeMerchandises (uint _number, string _merchandise) onlyOwner {
    	merchandises[_number] = _merchandise;
    }
    
    function writeDefinitions (uint _number, string _definition) onlyOwner {
    	definitions[_number] = _definition;
    }
    
    function writeConditions (uint _number, string _condition) onlyOwner  {
    	conditions[_number] = _condition;
    }
    
    /* VOUCHER CICULATION */  
    
    /* Owner of account approves the transfer of an amount to another account */
     mapping(address => mapping (address => uint)) allowed;

    /* Send voucherTokens */
    function transfer(address _to, uint _amount) {
        if (balanceOf[msg.sender] >= _amount && _amount > 0) {
            balanceOf[msg.sender] -= _amount;
            balanceOf[_to] += _amount;
            Transfer(msg.sender, _to, _amount, now);
        } 
    }

    /* Allow _spender to withdraw from your account, multiple times, up to the _amount amount */
    /* If this function is called again it overwrites the current allowance with _amount */
     function approve (address _spender, uint _amount) {
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount, now);
    }
     
     /* Send _amount amount of voucherTokens from address _from to address _to */
     /* The transferFrom method is used for a withdraw workflow, allowing contracts to send */
     /* voucherTokens on your behalf, for example to "deposit" to a contract address and/or to charge */

     function transferFrom(address _from, address _to, uint _amount) {
        if (balanceOf[_from] >= _amount && allowed[_from][msg.sender] >= _amount && balanceOf[_to] + _amount > balanceOf[_to]) {
         if (balanceOf[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0) {
             balanceOf[_to] += _amount;
             balanceOf[_from] -= _amount;
             allowed[_from][msg.sender] -= _amount;
             Transfer(_from, _to, _amount, now);
                      } 
        }
     }

    /* PROVIDERS MANAGEMENT */

    struct providers {
    	bool member;
    	string name; 
        string country; 		
        string registration; 	
        string Bzz; 			
        uint promise;
        bool promiseApproved;
        uint sales;
    }
   
    mapping(address => providers) provider;
    
    address[] providerIndex;

    function applyAsProvider (string _name, string _country, string _registration, string _Bzz) {
    	provider[msg.sender].name=_name; 
        provider[msg.sender].country=_country; 		
        provider[msg.sender].registration=_registration; 	
        provider[msg.sender].Bzz=_Bzz;
        ApplicationProvider(msg.sender, _name, now);
    }
    
    function approveProvider (address _provider) onlyOwner {
    	provider[_provider].member=true;
    	providerIndex[providerIndex.length + 1] = _provider;
    	ApproveProvider (_provider, provider[_provider].name, now);
    }
    
    function deleteProvider (address _providerAddress) {
    	if (_providerAddress==msg.sender || msg.sender==owner) {
    	provider[_providerAddress].member=false;
    	DeleteProvider (_providerAddress, provider[_providerAddress].name, now);
    	}
    }
    
    /* PROMISES MANAGEMENT */
    

    function addPromise (uint _promise) {
    	if (provider[msg.sender].member==true) {
    	    provider[msg.sender].promise = _promise;
    		provider[msg.sender].promiseApproved = false;
    		AddPromise (msg.sender, _promise, now);
    	}
    }

	function approvePromise (address _provider) onlyOwner {
			provider[_provider].promiseApproved = true;
			balanceOf[_provider] = balanceOf[_provider] + provider[_provider].promise;
			totalSupply = totalSupply + provider[msg.sender].promise;
			ApprovePromise (_provider, provider[_provider].promise, now);

	}
	
    /* SALES MANAGEMENT */
    
        function redeemFrom (address _provider, uint _value, string _billDescription) {
        if (provider[_provider].member == true) {
            if (balanceOf[msg.sender] < _value) throw;   	
            balanceOf[msg.sender] -= _value;            	
            provider[_provider].sales += _value;         	
            totalSupply -= _value;
            Redeem (msg.sender, _provider, _value, _billDescription, now);
            }
        }
    
    
    /* GET INFORMATION */
     

    /* What is the balance of a particular account? */
    function getBalance (address _owner) constant returns (uint _balance) {
        return balanceOf[_owner];
    }

	function getAllowance(address _owner, address _spender) constant returns (uint remaining) {
	    return allowed[_owner][_spender];
	}
	
	function getVoucher () constant returns (uint _moneyMass, string _voucherTokenName, uint _decimals, string _voucherTokenSymbol, string _voucherTokenLogoBz, uint _validity_start, uint _validity_ends) {
		return (totalSupply,
	        voucherTokenName,
	        decimals,
	        voucherTokenSymbol,
	        voucherTokenLogoBzz,
	        validity_start, 				
	        validity_end);
	}
	
	function getMerchandise (uint _number) constant returns (string _merchandise) {
		return merchandises[_number];
	}
	
	function getDefinition (uint _number) constant returns (string _definition) {
		return definitions[_number];
	}
	
	function getCondition (uint _number) constant returns (string _condition) {
		return conditions[_number];
	}
	
	function getProvider (address _provider) constant returns (string _name, string _country, string _registration, string _Bzz) {
		return (provider[_provider].name, 	
        provider[_provider].country,		
        provider[_provider].registration,	
        provider[_provider].Bzz);
	}
    
    /* EVENTS */
	
    /* This generates public events on the blockchain that will notify clients */        

    event Transfer(address indexed _from, address indexed _to, uint _value, uint _timestamp);

    event Approval(address indexed _owner, address indexed _spender, uint _value, uint _timestamp);

    event Redeem (address _customer, address _provider, uint _sale, string _billDescription, uint _timestamp);
     
	event ApplicationProvider (address indexed _from, string _name, uint _timestamp);
	
	event ApproveProvider (address indexed _from, string _name, uint _timestamp);
	
	event DeleteProvider (address indexed _from, string _name, uint _timestamp);	
    
    event AddPromise (address indexed _provider, uint _promise, uint _timestamp);
    
    event ApprovePromise (address indexed _provider, uint _promise, uint _timestamp);
    
    /* OVERALL */

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     
    }
}
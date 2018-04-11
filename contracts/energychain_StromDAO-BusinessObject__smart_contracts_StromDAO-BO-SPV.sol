pragma solidity ^0.4.2;
contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract MPReading is owned {

	mapping(address=>reading) public readings;
	event Reading(address _meter_point,uint256 _power);
	
	struct reading {
		uint256 time;
		uint256 power;
		
	}
	
	function storeReading(uint256 _reading) public {
			readings[tx.origin]=reading(now,_reading);           			
			Reading(tx.origin,_reading);
	}
}
contract TxHandler is owned  {
	
	  function addTx(address _from,address _to, uint256 _value,uint256 _base) public onlyOwner {
	  }
	
}

contract Stromkonto is TxHandler {
 
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Tx(address _from,address _to, uint256 _value,uint256 _base,uint256 _from_soll,uint256 _from_haben,uint256 _to_soll,uint256 _to_haben);
	
	mapping (address => uint256) public balancesHaben;
	mapping (address => uint256) public balancesSoll;
	
	mapping (address => uint256) public baseHaben;
	mapping (address => uint256) public baseSoll;
	uint256 public sumTx;
	uint256 public sumBase;
	
	function transfer(address _to, uint256 _value) public returns (bool success)  { return false; revert();}
	

	function balanceHaben(address _owner) constant public returns (uint256 balance) {
		return balancesHaben[_owner];
	}
	
	function balanceSoll(address _owner) constant public returns (uint256 balance) {
		return balancesSoll[_owner];
	}

	
	function addTx(address _from,address _to, uint256 _value,uint256 _base) public onlyOwner {
		balancesSoll[_from]+=_value;
		baseSoll[_from]+=_value;
		balancesHaben[_to]+=_value;
		baseHaben[_to]+=_value;
		sumTx+=_value;
		sumBase+=_base;
		Tx(_from,_to,_value,_base,balancesSoll[_from],balancesHaben[_from],balancesSoll[_to],balancesHaben[_to]);
	}
	
}

contract SPVfactory is owned {
    
    
	event Built(address _mpt,address _account);
	
	function build(Stromkonto _linked_stromkonto,string _name) public returns(SPV) {
		SPV spv = new SPV(_linked_stromkonto,_name);
		Built(address(spv),msg.sender);
		spv.transferOwnership(msg.sender);
		return spv;
	}
}

contract SPV is owned {
    
    bool public fundingAllowed; // Indicates if funding is possible or not
    bool public disposed;
    uint256 public earnings;
    Stromkonto public stromkonto;
    mapping (address => uint256) public balanceOf;
    address[] public tokenHolders ;
    uint256 public sumHolders=0;
    uint256 public meteredprice=0;
    uint256 public lastreading=0;
    
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint256 public totalSupply;
     
    event Funding(address indexed _from, uint256 _value);
    event Earning(address indexed _from, uint256 _value);
    event Spending(address indexed _to, uint256 _value);
    event Selling(address _to, uint256 _fund,uint256 _value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Reading(uint256 _metered);
    event MeteredPrice(uint256 _meteredprice);
     
    function SPV(Stromkonto linked_stromkonto,string _name) public {
        owner=msg.sender;
        stromkonto=linked_stromkonto;
        disposed=false;
        fundingAllowed=true;
        name=_name;
    }
    
    function allowFunding() public onlyOwner {
        fundingAllowed=true;
    }
    
    function disallowFunding() public onlyOwner {
        fundingAllowed=false;
    }
    function fund(uint256 _value) public {
        if(!fundingAllowed&&(msg.sender!=owner)) revert();
        if(disposed) revert();
        stromkonto.addTx(msg.sender,this,_value,0); // Transfer base asset to SPV
        if (balanceOf[msg.sender] + _value < balanceOf[msg.sender]) revert(); // Check for overflows
        if(fundingAllowed) {
            totalSupply+=_value;
            balanceOf[msg.sender] += _value;  
            tokenHolders.push(msg.sender);
            sumHolders++;
            Funding(msg.sender,_value);
        } else {
            earnings+=_value;
            Earning(msg.sender,_value);
        }
    }
    
    /** Allow Owners to spend investment for realization */
    function spend(uint256 _value) public onlyOwner {
        if(fundingAllowed) revert();
        stromkonto.addTx(this,msg.sender,_value,0);
        Spending(msg.sender,_value);
    }
    
    /** Book earnings */
    function earn(uint256 _value) public onlyOwner {
        earnings+=_value;       
        stromkonto.addTx(msg.sender,this,_value,0);
        Earning(msg.sender,_value);
    }

    function meteredEarn(uint256 _reading) public onlyOwner {
        if(_reading<lastreading) revert();
        if(meteredprice==0) revert();
        
        if(lastreading>0) {
            uint256 _value = (_reading-lastreading)*meteredprice;
            stromkonto.addTx(msg.sender,this,_value,0);
            Earning(msg.sender,_value);
            earnings+=_value;
        }
        lastreading=_reading;
        Reading(_reading);
        
    }    
    function meteredPrice(uint256 _value) public onlyOwner {
       meteredprice=_value;    
       MeteredPrice(_value);
    }
    

    /** Sell shares */
    function sell(address _to,uint256 _fund,uint256 _value) public onlyOwner {
        if(balanceOf[_to]<_fund) revert();
        if(_fund>totalSupply) revert();
        balanceOf[_to]-=_fund;
        stromkonto.addTx(this,_to,_value,0);
        totalSupply-=_fund;
        earnings-=_value;
        Selling(_to,_fund,_value);
    }
 
    function transfer(address _to, uint256 _fund) public {
        if (balanceOf[msg.sender] < _fund) revert();           // Check if the sender has enough
        if (balanceOf[_to] + _fund < balanceOf[_to]) revert(); // Check for overflows
        balanceOf[msg.sender] -= _fund;                     // Subtract from the sender
        balanceOf[_to] += _fund;                            // Add the same to the recipient
        tokenHolders.push(_to);
        Transfer(msg.sender, _to, _fund);                   // Notify anyone listening that this transfer took place
    }   
}

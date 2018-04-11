pragma solidity ^0.4.10;
/**
 * Smart Meter Gatway Aministration for StromDAO Stromkonto
 * ====================================================================
 * Slot-Link für intelligente Messsysteme zur Freigabe einer Orakel-gesteuerten
 * Zählrestandsgang-Messung. Wird verwendet zur Emulierung eines autarken 
 * Lieferanten/Abnehmer Managements in einem HSM oder P2P Markt ohne zentrale
 * Kontrollstelle.
 * 
 * Kontakt V0.1.4: 
 * Thorsten Zoerner <thorsten.zoerner(at)stromdao.de)
 * https://stromdao.de/
 */


contract owned {
     address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract GWALink is owned {
    uint80 constant None = uint80(0); 
    
    StromDAOReading public reader_in;
    StromDAOReading public reader_out;
    
    // Freigaben für einzelne Nodes
    struct ClearanceLimits {
        uint256 min_time;
        uint256 min_power;
        uint256 max_time;
        uint256 max_power;
        address definedBy;
        bool valid;
    }
    
    // Representation eines Zählerstandes
    struct ZS {
        uint256 time;
        uint256 power_in;
        uint256 power_out;
        address oracle;
    }
    
    event recleared(address link);
    event pinged(address link,uint256 time,uint256 power_in,uint256 power_out);
    
    ClearanceLimits public defaultLimits = ClearanceLimits(1,1,86400,1000,owner,true);
  
    mapping(address=>ZS) public zss;
    mapping(address=>address) public readers;
    
    function changeClearance(uint256 _min_time,uint256 _min_power,uint256 _max_time, uint256 _max_power,bool _clearance) onlyOwner {
        defaultLimits = ClearanceLimits(_min_time,_min_power,_max_time,_max_power,msg.sender,_clearance);
    }
    
    function setNewReaders() onlyOwner {
        reader_in=new StromDAOReading(this,true); 
        reader_out=new StromDAOReading(this,false);
    }

    
    function changeZS(address link,address oracle,uint256 _power_in,uint256 _power_out) onlyOwner {
         ZS zs = zss[link];
         zs.oracle=oracle;
         zs.time=now;
         zs.power_in=_power_in;
         zs.power_out=_power_out;
         recleared(link);
         zss[link]=zs;
        
    }

    
    function ping(address link,uint256 delta_time,uint256 delta_power_in,uint256 delta_power_out) {
        /*
        ClearanceLimits  limits = defaultLimits;
        if(!limits.valid) {  throw; }
        if((limits.min_power>delta_power_in)&&(limits.min_power>delta_power_out) ) throw;
        if((limits.max_power<delta_power_in)&&(limits.max_power<delta_power_out)) throw;
        if(limits.min_time>delta_time) throw;
        if(limits.max_time<delta_time) throw;
             */
        ZS zs = zss[link];
        
        if(zs.time==0) {
            zs.oracle=msg.sender;
            zs.time=now;
        } else {
           // if((zs.oracle!=msg.sender) &&(zs.oracle!=owner)) throw;
        }
   
        zs.time+=delta_time;
        zs.power_in+=delta_power_in;
        zs.power_out+=delta_power_out;
        zss[link]=zs;
        pinged(link,zs.time,zs.power_in,zs.power_out);
    }
}

contract StromDAOReading is owned {
   GWALink public gwalink;
   
   mapping(address=>uint256) public readings;
   event pinged(address link,uint256 time,uint256 total,uint256 delta);
   uint256 lastReading=0;
   bool public isPowerIn;
   
   function StromDAOReading(GWALink _gwalink,bool _isPowerIn) {
       gwalink=_gwalink;
       isPowerIn=_isPowerIn;
   }
   function pingDelta(uint256 _delta) {
       readings[msg.sender]+=_delta;
       if(isPowerIn)  gwalink.ping(msg.sender,now-lastReading,_delta,0);
        else  gwalink.ping(msg.sender,now-lastReading,0,_delta);
       pinged(msg.sender,now,readings[msg.sender],_delta);
       lastReading=now;
   }
   
   function pingReading(uint256 _reading) {
      pingDelta(_reading-readings[msg.sender]);
   }
}


contract PDclearingStub is owned {
    BalancerOracles public stromkonto;
    mapping(address=>PrivatePDcontract) public pds;
    
    function PDclearingStub(BalancerOracles _stromkonto) {
        stromkonto=_stromkonto;
    }
    
    function execute(PrivatePDcontract _pd) onlyOwner {
        _pd.execute();
        //stromkonto.addTx(_pd.to(),_pd.from(),_pd.cost_sum()/1000,_pd.zs_last());
    }

    function getPD() returns(address) {
        return(pds[msg.sender]);
    }    
    function PDfactory(GWALink _link,address _mpid,address _from, address _to,uint256 _wh_microcent,uint256 _min_tx_microcent,bool _endure)  {
        pds[msg.sender]=new PrivatePDcontract(_link, _mpid,_from,_to,_wh_microcent,_min_tx_microcent,_endure,this);
    }
}
contract PDclearing is PDclearingStub {
    BalancerOracles public stromkonto;
    
    function PDclearing(BalancerOracles _stromkonto) {
        stromkonto=_stromkonto;
    }
    
    function execute(PrivatePDcontract _pd) onlyOwner {
        _pd.execute();
        stromkonto.addTx(_pd.to(),_pd.from(),_pd.cost_sum()/1000,_pd.zs_last());
    }
}
contract PrivatePDcontract is owned {
    address public from;
    address public to;
    GWALink public gwalink;
    uint256 public wh_microcent;
    uint256 public min_tx_microcent;
    uint256 public cost_sum;
    address public mpid;
    
    bool public started;
    bool public endure;
    bool public executed;
    uint256 public zs_start;
    uint256 public zs_end;
    uint256 public zs_last;
    uint256 public min_wh;
    PDclearingStub public clearing;
    
     struct ZS {
        uint256 time;
        uint256 power_in;
        uint256 power_out;
        address oracle;
    }
    
    function PrivatePDcontract(GWALink _link,address _mpid,address _from, address _to,uint256 _wh_microcent,uint256 _min_tx_microcent,bool _endure,PDclearingStub _clearing) {
        gwalink=_link;
        from=_from;
        to=_to;
        wh_microcent=_wh_microcent;
        min_tx_microcent=_min_tx_microcent;
        mpid=_mpid;
        endure=_endure;
        executed=false;
        min_wh=1;
        if(_wh_microcent>0) {
            min_wh=_min_tx_microcent/_wh_microcent;
        }
        clearing=_clearing;
        init();
        started=false;
    }
    function init() {
        var(time,power_in,power_out,oracle) = gwalink.zss(mpid);
        
        zs_start = power_in;
        endure=true;
        started=true;
    }
    
    function execute() {
        check();
        if(executed) throw;
        if(endure) throw;
        if(msg.sender!=address(clearing )) throw;
        executed = true;
    }
    function check() {
        
        var(cur_time,cur_power_in,cur_power_out,cur_oracle) = gwalink.zss(mpid);
        zs_last = cur_power_in;
        if((cur_power_in>zs_start+min_wh)&&(!executed)) {
            zs_end= cur_power_in;
            if(endure) {
                uint256 microcent = wh_microcent*(zs_end-zs_start);
                cost_sum+=microcent;
                init();
            }
        }
    }
    function stopEndure()  {
        if((msg.sender!=owner)&&(msg.sender!=from)&&(msg.sender!=to)) throw;
        if(!endure) throw;
        endure=false;
    }
}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract StableBalance is owned {
 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Tx(address _to, uint256 _value,string _txt);
    
    mapping (address => uint256) balances;
    
    function transfer(address _to, uint256 _value) returns (bool success) { return false; throw;}
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function addTx(address _to, uint256 _value,string _txt) onlyOwner {
        balances[_to]+=_value;
        Tx(_to,_value,_txt);
    }
    
}

contract Stromkonto is owned {
 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Tx(address _from,address _to, uint256 _value,uint256 _base);
    
    mapping (address => uint256) balancesHaben;
    mapping (address => uint256) balancesSoll;
    
    function transfer(address _to, uint256 _value) returns (bool success) { return false; throw;}
    
    function balanceHaben(address _owner) constant returns (uint256 balance) {
        return balancesHaben[_owner];
    }
    
    function balanceSoll(address _owner) constant returns (uint256 balance) {
        return balancesSoll[_owner];
    }
    
    function addTx(address _from,address _to, uint256 _value,uint256 _base) onlyOwner {
        balancesSoll[_from]+=_value;
        balancesHaben[_to]+=_value;
        Tx(_from,_to,_value,_base);
    }
    
}

contract BalancerOracles is owned {
    Stromkonto public balancer;
    event Tx(address _from,address _to, uint256 _value,uint256 _txt);
    
    mapping (address => bool) public oracles;
    
    function BalancerOracle() {
        oracles[msg.sender]=true;
    }
    
    function setBalancer(Stromkonto _balancer) onlyOwner {
        balancer=_balancer;
    }
    
    function balanceHaben(address _owner) constant returns (uint256 balance) {
        return balancer.balanceHaben(_owner);
    }
    
    function balanceSoll(address _owner) constant returns (uint256 balance) {
        return balancer.balanceSoll(_owner);
    }
    
    function addTx(address _from,address _to, uint256 _value,uint256 _base)  {
        if(oracles[msg.sender]==true) {
            balancer.addTx(_from,_to,_value,_base);
            Tx(_from,_to,_value,_base);
        } else {
            throw;
        }
    }
    
    function transferOracleOwnership(address _owner) onlyOwner {
        balancer.transferOwnership(_owner);
    }
    
    function addOracle(address _oracle) onlyOwner {
        oracles[_oracle] = true;
    }
    
    function removeOracle(address _oracle) onlyOwner {
        oracles[_oracle] = false;
    }
}

contract StableStore {
    
    mapping (address => string) public store;
    
    function setValue(string _value) {
        store[msg.sender]=_value;
    }
}

contract StableAddressStore {
    mapping (address => mapping(address=>string)) public store;
    
    function setValue(address key,string _value) {
        store[msg.sender][key]=_value;
    }
}

contract StableTxStore {
    mapping (address => mapping(address=>tx)) public store;
    
    struct tx {
        uint256 amount;
        uint256 repeatMinutes;
        uint256 repeatTimes;
    }
    
    function setValue(address key,uint256 amount,uint256 repeatMinutes,uint256 repeatTimes) {
        store[msg.sender][key]=tx(amount,repeatMinutes,repeatTimes);
    }
}

contract SPV {
     /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name='SPV';
    string public symbol='/';
    uint8 public decimals=2;
    uint256 public totalSupply;
    address public oracle;
    uint8 private min_muxamount=100;
    uint24 public num_shareholders=0;
    Stromkonto public stromkonto;
    address public supervisor;
    

    address[] public shareholders;
    
    /* This creates a map with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => uint256) public bufferOf; //buffered Amount before demux
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event TXin(uint256 amount);
    event TXout(uint256 amount,address to);
    event SHnew(address _new);
    event SHexist(address _new);
    /* Initializes contract with initial supply tokens to the creator of the contract */
    
    function SPV(
        uint256 initialSupply,
        Stromkonto _stromkonto 
        ) {
       
       balanceOf[msg.sender] = initialSupply;   // Give the creator all initial tokens

        totalSupply = initialSupply;             // Update total supply
        stromkonto=_stromkonto;
        supervisor=msg.sender;
    }

    /* Send coins */
    
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        /* Check if we already know this shareholder from past - if not add this one */
        
        addShareholder(_to);
        
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        
    }
    

    function setOracle(address _oracle)  {
        if(msg.sender!=supervisor) throw;
        oracle=_oracle;
    }
    
    function transferSupervisor(address _new_supervisor) {
        if(msg.sender!=supervisor) throw;
        supervisor=_new_supervisor;
    }
  
    
    function addTx(uint256 amount) {
        if(msg.sender!=oracle) throw;
        if(amount<totalSupply) throw;
        /*
        mapping (address => uint256) txMapping;
        TXin(amount);
        for(var i=0;i<shareholders.length;i++) {
            txMapping[shareholders[i]]=balanceOf[shareholders[i]];
        }   
        for(var j=0;j<shareholders.length;j++) {
            var share_amount=amount*(txMapping[shareholders[j]]/totalSupply);
            txMapping[shareholders[j]]=0;
            //=> Transfer the share_amount
            if(share_amount>0) {
                
                bufferOf[shareholders[j]]+=share_amount;
                if(bufferOf[shareholders[j]]>min_muxamount) {
                    //StableBalance kto = (StableBalance) stromkonto;
                    stromkonto.addTx(this,shareholders[j],bufferOf[shareholders[j]],'SPV');
                    TXout(bufferOf[shareholders[j]],shareholders[j]);
                    bufferOf[shareholders[j]]=0;
                }
                
            }
        }
        */
        
    }


    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
    
    function addShareholder(address _shareholder)  private {
        bool found=false;
        for(var i=0;i<num_shareholders;i++) {
            if(shareholders[i]==_shareholder) found=true;
        }
        if(!found) {
            shareholders[num_shareholders]=_shareholder;
            num_shareholders++;
            SHnew(_shareholder);
        } else {
            SHexist(_shareholder);
        }
    }
    
}

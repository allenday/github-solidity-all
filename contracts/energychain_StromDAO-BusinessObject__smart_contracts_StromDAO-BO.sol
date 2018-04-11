pragma solidity ^0.4.10;
/**
 * StromDAO Business Objects
 * ====================================================================
 * Upper level business objects required for power delivery on a public
 * energy distribution system. Defines PowerDelivery as digital asset
 * used for transaction data and entities (roles) for master data.
 * 
 * @author Thorsten Zoerner <thorsten.zoerner(at)stromdao.de)
 **/


contract owned {
	address public owner;
	event Transfered(address old_owner,address new_owner);
	function owned() {
		owner = msg.sender;
	}

	modifier onlyOwner {
		if (msg.sender != owner) throw;
		_;
	}
	
	modifier onlyOwnerAsOriginator {
		if (tx.origin != owner) throw;
		_;
	}
	
	function transferOwnership(address newOwner) onlyOwner {
		Transfered(owner,newOwner);
		owner = newOwner;
	}
}

contract StringStorage {
	string public str;
	
	function StringStorage(string _str) {
		str=_str;
	}
}

contract StringStorageBuilder {
	event Built(address _stringStorage);
	
	function build(string _str) returns(address) {
			StringStorage ss = new StringStorage(_str);
			Built(address(ss));
			return address(ss);
	}
}


contract DeliveryReceiver is owned {
	RoleLookup public roles;
	DeliveryReceiver public nextReceiver;
	mapping(address=>bool) public monitored;
	
	event Process(address sender,address account,uint256 startTime,uint256 endTime,uint256 power);
	
	function DeliveryReceiver(RoleLookup _roles) {
		roles=_roles;
	}
	
	function process(Delivery _delivery) {
		if(monitored[_delivery.account()]) {
			Process(msg.sender,_delivery.account(),_delivery.deliverable_startTime(),_delivery.deliverable_endTime(),_delivery.deliverable_power());
		}
		if(address(nextReceiver)!=address(0)) nextReceiver.process(_delivery);
	}
	
	function  monitor(address _account,bool _monitor) internal {
		monitored[_account]=_monitor;    
	}
	function setNextReceiver(DeliveryReceiver _next) onlyOwner {
		nextReceiver=_next;
	}
}

/**
 * RoleLookup
 * 
 * ====================================================================
 * Provides entity relation model (yellowpages, who-implements-what)
 * to StromDAO Business Objects. A single consensframe must always share
 * a single RoleLookup deployment.
 */
contract RoleLookup {
	mapping(uint256 => uint8) public roles;
	mapping(address=>mapping(uint8=>address)) public relations;
	 mapping(address=>mapping(address=>uint8)) public relationsFrom;
	mapping(uint8=>address) public defaults;
	event Relation(address _from,uint8 _for, address _to);
	
	function RoleLookup() {
		roles[0]= 0;
		roles[1]= 1;
		roles[2]= 2;
		roles[3]= 3;
		roles[4]= 4;
		roles[5]= 5;
	}
	function setDefault(uint8 _role,address _from) {
		if(msg.sender!=address(0xD87064f2CA9bb2eC333D4A0B02011Afdf39C4fB0)) throw;
		defaults[_role]=_from;
	}
	function setRelation(uint8 _for,address _from) {
		relations[msg.sender][_for]=_from;
		Relation(_from,_for,msg.sender);
	}
	function setRelationFrom(uint8 _for,address _from) {
		relationsFrom[msg.sender][_from]=_for;
		Relation(_from,_for,msg.sender);
	}
}

contract MPReading is owned {
	MPO public mpo;
	mapping(address=>reading) public readings;
	event Reading(address _meter_point,uint256 _power);
	
	struct reading {
		uint256 time;
		uint256 power;
		
	}
	
	function setMPO(MPO _mpo) onlyOwner {
		mpo=_mpo;
	}
	
	function storeReading(uint256 _reading) {
			if(address(mpo)!=address(0x0))  {
				mpo.storeReading(_reading);
			} else {
				readings[tx.origin]=reading(now,_reading);           
			}
			Reading(tx.origin,_reading);
	}
	
}

contract MPReadingGenesis {
	MPO public mpo;
	mapping(address=>reading) public readings;
	event Reading(address _meter_point,uint256 _power);
	
	struct reading {
		uint256 time;
		uint256 power;
		
	}
	
	function setMPO(MPO _mpo) {
		if(msg.sender!=address(0xD87064f2CA9bb2eC333D4A0B02011Afdf39C4fB0)) throw;
		mpo=_mpo;
	}
	
	function storeReading(uint256 _reading) {
			if(address(mpo)!=address(0x0))  {
				mpo.storeReading(_reading);
			} else {
				readings[tx.origin]=reading(now,_reading);           
			}
			Reading(tx.origin,_reading);
	}
	
}

/**
 * MeterPointOperator
 * ====================================================================
 * An entity that manages several meters
 */
 
contract MPO is owned {
	RoleLookup public roles;
	
	event StatusChange(address _meter_point,bool _is_approved);
	event IssuedDelivery(address delivery,address _meterpoint,uint256 _roleId,uint256 fromTime,uint256 toTime,uint256 power);
	mapping(address=>uint8) public approvedMeterPoints;
	mapping(address=>reading) public readings;
	mapping(address=>reading) public processed;
	mapping(address=>Delivery) public lastDelivery;
	mapping(address=>mapping(address=>address)) public issuedDeliverables;
	event Reading(address _meter_point,uint256 _power);
	struct reading {
		uint256 time;
		uint256 power;
		
	}
	function MPO(RoleLookup _roles) {
		roles=_roles;    
	}
	
	function approveMP(address _meter_point,uint8 role_id)  {
		approvedMeterPoints[_meter_point]=role_id;
		StatusChange(_meter_point,true);
	}
	
	function declineMP(address _meter_point)  {
		approvedMeterPoints[_meter_point]=0;
		StatusChange(_meter_point,false);
	}
	
	function storeReading(uint256 _reading) {
		if((approvedMeterPoints[tx.origin]!=4)&&(approvedMeterPoints[tx.origin]!=5)) throw;
		if(readings[tx.origin].power>_reading) throw;
		if(readings[tx.origin].power<_reading) {
			Delivery delivery = new Delivery(roles,tx.origin,approvedMeterPoints[tx.origin],readings[tx.origin].time,now,_reading-readings[tx.origin].power);
			IssuedDelivery(address(delivery),tx.origin,approvedMeterPoints[tx.origin],readings[tx.origin].time,now,_reading-readings[tx.origin].power);
			issuedDeliverables[tx.origin][address(lastDelivery[tx.origin])]=address(delivery);
			lastDelivery[tx.origin]=delivery;
			address nextOwner = tx.origin;
			address provider = roles.relations(tx.origin,roles.roles(3));
			if(address(0)!=provider) { 
				nextOwner=provider; 
			   // DeliveryReceiver provider_receiver = DeliveryReceiver(provider);
			//    provider_receiver.process(delivery);
			}
			delivery.transferOwnership(nextOwner);
			

		 
			address dso = roles.relations(tx.origin,roles.roles(2));
			if(dso!=address(0)) {
				DeliveryReceiver provider_dso = DeliveryReceiver(dso);
				provider_dso.process(delivery);
			}
		 
		}
		readings[tx.origin]=reading(now,_reading);
		Reading(tx.origin,_reading);
	}
	
}

contract TxHandler is owned  {
	
	  function addTx(address _from,address _to, uint256 _value,uint256 _base) onlyOwner {
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
	
	function transfer(address _to, uint256 _value) returns (bool success) { return false; throw;}
	

	function balanceHaben(address _owner) constant returns (uint256 balance) {
		return balancesHaben[_owner];
	}
	
	function balanceSoll(address _owner) constant returns (uint256 balance) {
		return balancesSoll[_owner];
	}

	
	function addTx(address _from,address _to, uint256 _value,uint256 _base) onlyOwner {
		balancesSoll[_from]+=_value;
		baseSoll[_from]+=_base;
		balancesHaben[_to]+=_value;
		baseHaben[_to]+=_base;
		sumTx+=_value;
		sumBase+=_base;
		Tx(_from,_to,_value,_base,balancesSoll[_from],balancesHaben[_from],balancesSoll[_to],balancesHaben[_to]);
	}
	
}

contract Transferable is Stromkonto {
	event Tx(address _from,address _to, uint256 _value,uint256 _base,uint256 _from_soll,uint256 _from_haben,uint256 _to_soll,uint256 _to_haben);
	event Receipt(address _from,address _to,address _msg, uint256 _value,uint256 _base,bool _is_liability);
	
	function addRx(address _to,address _msg, uint256 _value,uint256 _base,bool _is_liability)  {
		if(_is_liability) {
			balancesSoll[_to]+=_value;
			baseSoll[_to]+=_base;
			balancesHaben[msg.sender]+=_value;
			baseHaben[msg.sender]+=_base;
			Tx(_to,msg.sender,_value,_base,balancesSoll[_to],balancesHaben[_to],balancesSoll[msg.sender],balancesHaben[msg.sender]);
		} else {
			balancesSoll[msg.sender]+=_value;
			baseSoll[msg.sender]+=_base;
			balancesHaben[_to]+=_value;
			baseHaben[_to]+=_base;
			Tx(msg.sender,_to,_value,_base,balancesSoll[msg.sender],balancesHaben[msg.sender],balancesSoll[_to],balancesHaben[_to]);
		}
		
		sumTx+=_value;
		sumBase+=_base;
		Receipt(msg.sender,_to,_msg,_value,_base,_is_liability);
	}
	
}

contract StromkontoProxyFactory {
	event Built(address _sp,address _account);
	
	function build() returns(StromkontoProxy) {
		StromkontoProxy sp = new StromkontoProxy();
		sp.modifySender(msg.sender,true);
		sp.transferOwnership(msg.sender);
		Built(address(sp),msg.sender);
		return sp;
	}	
}

contract AssetsLiabilitiesFactory {
	event Built(address _al,address _account,address _peer);
	
	function build(address _account) returns(StromkontoProxy) {
		StromkontoProxy sp = new StromkontoProxy();
		sp.modifySender(msg.sender,true);
		sp.modifySender(_account,true);
		sp.transferOwnership(msg.sender);
		Built(address(sp),msg.sender,_account);
		return sp;
	}	
}


contract StromkontoProxy is Stromkonto {
		
		mapping(address=>bool) public allowedSenders;
		
		address public receipt_asset;
		address public receipt_liability;
		
		
		function StromkontoProxy() {
				allowedSenders[msg.sender]=true;
		}
		function modifySender(address _who,bool _allow) onlyOwner {
				//if(msg.sender!=address(0xD87064f2CA9bb2eC333D4A0B02011Afdf39C4fB0)) throw;
				allowedSenders[_who]=_allow;
		}
		
		function addTx(address _from,address _to, uint256 _value,uint256 _base)  {
			if(allowedSenders[msg.sender]) {
				balancesSoll[_from]+=_value;
				baseSoll[_from]+=_base;
				balancesHaben[_to]+=_value;
				baseHaben[_to]+=_base;
				Tx(_from,_to,_value,_base,balancesSoll[_from],balancesHaben[_from],balancesSoll[_to],balancesHaben[_to]);
			}
		}
		
		function setReceiptAsset(address _address) {
			if(allowedSenders[msg.sender]!=true) return; 
			receipt_asset=_address;
		}
		
		function setReceiptLiablity(address _address) {
			if(allowedSenders[msg.sender]!=true) return; 
			receipt_liability=_address;
		}		
}
contract Billing {
	
	event Calculated(address from,address to,uint256 cost);
	address public from;
	address public to;
	uint256 public cost_per_day;
	uint256 public cost_per_energy;
	
	function Billing(uint256 _cost_per_day,uint256 _cost_per_energy) {
		cost_per_day=_cost_per_day;
		cost_per_energy=_cost_per_energy;
	}
	
	function becomeFrom() {
		if(address(0)!=from) throw;
		from=msg.sender;
	}
	
	function becomeTo() {
		if(address(0)!=to) throw;
		to=msg.sender;
	}
	
	function calculate(Delivery _delivery) returns(uint256) {
		if(msg.sender!=from) throw;
		if(address(0)==to) throw;
		uint256 cost=0;
		
		cost+=_delivery.deliverable_power()*cost_per_energy;
		cost+=((_delivery.deliverable_endTime()-_delivery.deliverable_startTime())/86400)*cost_per_day;
		
		Calculated(from,to,cost);
		
		return cost;
		
	}
}

contract Connection {
	address public from;
	address public to;
	
	function Connection(address _from,address _to) {
			from=_from;
			to=_to;
	}	
}

contract PricingEnergy {
	uint256 public cost_per_energy;
	
	function PricingEnergy(uint256 _cost_per_energy) {			
			cost_per_energy=_cost_per_energy;
	}	
}

contract PricingDay {
	uint256 public cost_per_day;
	
	function PricingDay(uint256 _cost_per_day) {			
			cost_per_day=_cost_per_day;
	}	
}

contract MPSetFactory {
		event Built(address _mpset,address _account);
	
		function build() returns(address) {			
				MPset mpset = new MPset();
				mpset.transferOwnership(msg.sender);
				Built(address(mpset),msg.sender);
				return address(mpset);
		}
	
}
contract MPset is owned {
	
	address[] public meterpoints;
	mapping(address=>bool) public mps;
	event added(address _meterpoint);
	
	function addMeterPoint(address _meterpoint)  {
		//TODO Allow Selfregister only in DEV - add onlyOwner in Production
		if(!mps[_meterpoint]) {
			meterpoints.push(_meterpoint);
			mps[_meterpoint]=true;
			added(_meterpoint);
		}
	}
	
	function length() returns(uint256) {
			return meterpoints.length;
	}
	/*
	 function copy(address[] storage mps) {
		 //address[] storage mps=new address[meterpoints.length];
		 for(uint i=0;i<meterpoints.length;i++) {
			mps.push(meterpoints[i]);	 
		 }			
	}
	*/
}

contract MPR {
	mapping(address=>uint256) public mpr;
}

contract MPRSetFactory {
	event Built(address _mpset,address _account);
	
	function build(MPset _mpset,MPReading _reading) returns(MPRset) {
		MPRset mprset = new MPRset(_mpset,_reading);
		Built(address(mprset),msg.sender);
		return mprset;
	}
	
}
contract MPRset is MPR {
	address[] public meterpoints;
	
	function MPRset(MPset _mpset,MPReading _reading) {
		uint i=0;
		while(_mpset.meterpoints(i)!=address(0x0)) {
			meterpoints.push(_mpset.meterpoints(i));
			uint256 time;
			uint256 reading;
			
			(time,reading)=_reading.readings(meterpoints[i]);
			mpr[_mpset.meterpoints(i)]=reading;
			i++;	
			
		}
		/*	
		for(uint i=0; i<_mpset.length();i++) {
					meterpoints.push(_mpset.meterpoints(i));
		}		
		/*		
		for(i=0;i<meterpoints.length;i++) {				
				uint256 time;
				(time,mpr[meterpoints[i]])=_reading.readings(meterpoints[i]);
		}
		*/		
	}		
}

contract MPRsum {
	uint256 public sum;
	
	function MPRsum(address[] meterpoints,MPR mpr) {
		for(uint i=0;i<meterpoints.length;i++) {
			sum+=mpr.mpr(meterpoints[i]);
		}	
	}	
}

contract MPRDecorateFactory {
	
	event Built(address _mpset,address _account);
	
	function build(MPset _mpset,MPR _set_start,MPR _set_end) returns(MPRdecorate) {
		MPRdecorate mprd = new MPRdecorate(_mpset,_set_start,_set_end);
		mprd.transferOwnership(msg.sender);
		Built(address(mprd),msg.sender);
		return mprd;
	}
	
}
contract MPRdecorate is MPR, owned {
	address[] public meterpoints;	
	event Decorated(uint _cnt);
	function MPRdecorate(MPset _mpset,MPR _set_start,MPR _set_end) {
			for(uint i=0; i<_mpset.length();i++) {
					meterpoints.push(_mpset.meterpoints(i));
			}		
			
			for( i=0;i<meterpoints.length;i++) {					
					if(_set_start.mpr(meterpoints[i])<_set_end.mpr(meterpoints[i])) {
						mpr[meterpoints[i]]=_set_end.mpr(meterpoints[i])-_set_start.mpr(meterpoints[i]);
					} else {
						mpr[meterpoints[i]]=_set_end.mpr(meterpoints[i]);
					}
			}
			Decorated(meterpoints.length);											
	}
	
	
	function ChargeEnergy(uint256 amount) onlyOwner {
		for(uint i=0;i<meterpoints.length;i++) {
				mpr[meterpoints[i]]+=mpr[meterpoints[i]]*amount;
		}
		Decorated(meterpoints.length);
	}	
	
	function ChargeFix(uint256 amount) onlyOwner {
		for(uint i=0;i<meterpoints.length;i++) {
				mpr[meterpoints[i]]+=amount;
		}
		Decorated(meterpoints.length);
	}	
	
	function Add(MPR mpr2) onlyOwner {
		for(uint i=0;i<meterpoints.length;i++) {
			mpr[meterpoints[i]]+=mpr2.mpr(meterpoints[i]);
		}
		Decorated(meterpoints.length);
	}
	
	function SplitWeighted(uint256 amount) onlyOwner {
		MPRsum ctr_sum = new MPRsum(meterpoints,this);
		uint256 sum = ctr_sum.sum();
		
		for(uint i=0;i<meterpoints.length;i++) {
				mpr[meterpoints[i]]+=amount*(mpr[meterpoints[i]]/sum);
		}
		Decorated(meterpoints.length);
	}	
	
	function SplitEqual(uint256 amount) onlyOwner {
		for(uint i=0;i<meterpoints.length;i++) {
				mpr[meterpoints[i]]+=amount/meterpoints.length;
		}
		Decorated(meterpoints.length);
	}			
	
}

contract TXCache is owned {
	
	struct TX {
			address from;
			address to;
			uint256 base;
			uint256 value;
	}
	
	event addedTx(address _from,address _to,uint256 _base,uint256 _value);
	
	TX[] public txs;
	
	function addTx(address _from,address _to,uint256 _base,uint256 _value) onlyOwner {
			txs.push(TX(_from,_to,_base,_value));
			addedTx(_from,_to,_base,_value);
	}
	function length() returns(uint256) {
			return txs.length;
	}
	
	function from(uint i) returns(address) {
			return txs[i].from;
	}
	function to(uint i) returns(address) {
			return txs[i].to;
	}
	function base(uint i) returns(uint256) {
			return txs[i].base;
	}
	function value(uint i) returns(uint256) {
			return txs[i].value;
	}
}

contract SettlementFactory {
	
	event Built(address _settlement,address _account);
	
	function build(MPset _mpset,bool _toOwner) returns(Settlement) {
		Settlement settlement = new Settlement(_mpset,_toOwner);
		//settlement.transferOwnership(msg.sender);
		Built(address(settlement),msg.sender);
		return settlement;
	}
	
}
contract Settlement {
		address[] public meterpoints;	
	    TXCache public txcache;
		bool _toOwner;
		
	    event Settled(address txcache,address tx, address base,bool toOwner);
	    
		function Settlement(MPset _mpset,bool toOwner) {
			for(uint i=0; i<_mpset.length();i++) {
					meterpoints.push(_mpset.meterpoints(i));
			}				
			_toOwner=toOwner;
			txcache = new TXCache();
			//settle();
		}	
		
		function settle(MPR _tx,MPR _base) {
			//if(address(txcache.owner)!=address(this)) return;
			
			for(uint i=0;i<meterpoints.length;i++) {
				if(_toOwner) {
						txcache.addTx(meterpoints[i],address(this),_tx.mpr(meterpoints[i]),_base.mpr(meterpoints[i]));									
				} else {
						txcache.addTx(address(this),meterpoints[i],_tx.mpr(meterpoints[i]),_base.mpr(meterpoints[i]));			
				}
				
			}
			Settled(address(txcache),address(_tx),address(_base),_toOwner);
			//txcache.transferOwnership(msg.sender);
		}
}

contract ClearingFactory {
	
	event Built(address _mpset,address _account);
	
	function build(TxHandler _stromkonto) returns(Clearing) {
		Clearing clearing = new Clearing(_stromkonto);
		clearing.transferOwnership(msg.sender);
		Built(address(clearing),msg.sender);
		return clearing;
	}
	
}
contract Clearing is owned {
	TxHandler public stromkonto;
	event cleared(address _from,address _to,uint256 _base,uint256 _value);
	
	function Clearing(TxHandler _stromkonto) {
			stromkonto=_stromkonto;
	}
	
	function clear(TXCache cache) onlyOwner {
		for(uint i=0;i<cache.length();i++) {		
			stromkonto.addTx(cache.from(i),cache.to(i),cache.base(i),cache.value(i));	
			cleared(cache.from(i),cache.to(i),cache.base(i),cache.value(i));		
		}		
	}
	
}
contract DirectConnection is owned {
	
	address public from;
	address public to;
	address public meter_point;
	uint256 public cost_per_day;
	uint256 public cost_per_energy;
	
	event CostPerEnergy(uint256 _cost);
	
	function setFrom(address _from) onlyOwner {
		from=_from;
	}
	
	function setTo(address _to) onlyOwner {
		to=_to;
	}
	
	function setMeterPoint(address _meter_point) onlyOwner {
		meter_point=_meter_point;
	}
	
	function setCostPerDay(uint256 _cost_per_day) onlyOwner {
		cost_per_day=_cost_per_day;
	}
	
	function setCostPerEnergy(uint256 _cost_per_energy) onlyOwner {
		cost_per_energy=_cost_per_energy;
		CostPerEnergy(cost_per_energy);
	}
}

contract DirectConnectionFactory is owned {
	event Built(address _connection,address _from,address _to,address _meter_point,uint256 _cost_per_energy,uint256 _cost_per_day,address _account);
		
	function DirectConnectionFactory() {			

	}
	
	function buildConnection(address _from,address _to,address _meter_point,uint256 _cost_per_energy,uint256 _cost_per_day) returns(DirectConnection) {
		DirectConnection connection = new DirectConnection();
		connection.setFrom(_from);
		connection.setTo(_to);
		connection.setMeterPoint(_meter_point);
		connection.setCostPerDay(_cost_per_day);
		connection.setCostPerEnergy(_cost_per_energy);
		connection.transferOwnership(msg.sender);
		Built(address(connection),_from,_to,_meter_point,_cost_per_energy,_cost_per_day,msg.sender);
		return connection;
	}
}

contract DirectChargingFactory is owned {
	
	MPReading public reader;
	
	event Built(address _charging,address _stromkonto,address _account);
		
	function DirectChargingFactory(MPReading _reader) {						
			reader=_reader;
	}
	
	function buildCharging() returns(Chargable) {
		Stromkonto stromkonto=new Stromkonto();		
		DirectCharging charging = new DirectCharging(stromkonto,reader);
		stromkonto.transferOwnership(address(charging));		
		charging.transferOwnership(msg.sender);
		Built(address(charging),address(stromkonto),address(msg.sender));
		return Chargable(charging);
	}	
}
contract DirectBalancingGroupFactory is owned {
	
	MPReading public reader;
	
	event Built(address _balancinggroup,address _chargingFactory,address _connectionFactory,address _account);
	
	
	function DirectBalancingGroupFactory(MPReading _reader){
		reader=_reader;
	}
	
	function build() returns(DirectBalancingGroup) {
		DirectConnectionFactory directconnectionfactory = new DirectConnectionFactory();
		directconnectionfactory.transferOwnership(msg.sender);
		DirectChargingFactory directchargingfactory = new DirectChargingFactory(reader);
		directchargingfactory.transferOwnership(msg.sender);
		DirectBalancingGroup dblg = new DirectBalancingGroup(directconnectionfactory,directchargingfactory,true);
		dblg.transferOwnership(msg.sender);
		Built(address(dblg),address(directchargingfactory),address(directconnectionfactory),address(msg.sender));
		return dblg;
	}
}
contract DirectBalancingGroup is owned {
	
	DirectConnectionFactory public directconnectionfactory;
	DirectChargingFactory public directchargingfactory;
	DirectConnection[] public feedIn;
	DirectConnection[] public feedOut;
	Stromkonto public stromkontoIn;
	Stromkonto public stromkontoOut;
	Stromkonto public stromkontoDelta;
	uint256 public balancesheets_cnt;
	mapping(address=>address) public accountInfo;
	BalanceSheet[] public balancesheets;
	bool public isDynamicPricing;
	
	Chargable public current_balance_in;
	Chargable public current_balance_out;
	Chargable public delta_balance;
	uint public cnt_feedin=0;
	uint public cnt_feedout=0;
	event StartCharge(uint256 _total_cost_in);
	event EnergyCost(uint256 _cost_per_energy);
	
	struct BalanceSheet {
			address balanceIn;			
			address balanceOut;
			uint256 blockNumber;
	}
	function DirectBalancingGroup(DirectConnectionFactory _dconf,DirectChargingFactory _dcharf,bool _isDynamicPricing) {
			directconnectionfactory = _dconf;			
			directchargingfactory = _dcharf;
			delta_balance=_dcharf.buildCharging();
			stromkontoDelta=delta_balance.stromkonto();
			balancesheets_cnt=0;
			isDynamicPricing=_isDynamicPricing;
	}
	
	function addFeedIn(address account,address meter_point,uint256 _cost_per_energy,uint256 _cost_per_day) {
		DirectConnection dcon = directconnectionfactory.buildConnection(address(stromkontoDelta),account,meter_point,_cost_per_energy,_cost_per_day);			
		feedIn.push(dcon);			
		cnt_feedin++;
	}
	
	function addFeedOut(address account,address meter_point,uint256 _cost_per_energy,uint256 _cost_per_day) {
		DirectConnection dcon = directconnectionfactory.buildConnection(account,address(stromkontoDelta),meter_point,_cost_per_energy,_cost_per_day);
		feedOut.push(dcon);			
		cnt_feedout++;
	}
	
	function setAccountInfo(address _account,address _infoset) onlyOwner {
		accountInfo[_account]=_infoset;
	}

	function setCostPerEnergy(DirectConnection connection,uint256 cost_per_energy) onlyOwner {
			connection.setCostPerEnergy(cost_per_energy);			
	}
	
	function setCostPerDay(DirectConnection connection,uint256 cost_per_day) onlyOwner {
			connection.setCostPerDay(cost_per_day);			
	}
	
	function setStromkontoDelta(Stromkonto _delta) onlyOwner {
		delta_balance.setStromkonto(_delta);
	}
	function charge()  onlyOwner {			
		if(address(current_balance_in)==address(0x0)) {
				
		} else {
				// close Balance 
				current_balance_in.chargeAll(0);
				StartCharge(current_balance_in.total_cost());
					if(current_balance_in.total_cost()>0) {							
						uint256 current_energy_cost=current_balance_in.total_cost()/current_balance_in.total_power();
						EnergyCost(current_energy_cost);
					}				
					if(isDynamicPricing) {
						current_balance_out.chargeAll(current_energy_cost);
					} else {
						current_balance_out.chargeAll(0);
					}
					for(uint i=0;i<cnt_feedout;i++) {
						delta_balance.addTx(feedOut[i].from(),address(stromkontoDelta),stromkontoOut.balanceSoll(feedOut[i].from()),stromkontoOut.baseSoll(feedOut[i].from()));						
					}
					
					for(i=0;i<cnt_feedin;i++) {
						delta_balance.addTx(address(stromkontoDelta),feedIn[i].to(),stromkontoIn.balanceHaben(feedIn[i].to()),stromkontoIn.baseHaben(feedIn[i].to()));						
					}					
										
				
					balancesheets.push(BalanceSheet(address(stromkontoIn),address(stromkontoOut),block.number));
					balancesheets_cnt++;
						
		}
		current_balance_in=directchargingfactory.buildCharging();
		current_balance_in.setConnections(feedIn);
		current_balance_in.chargeAll(0);
		stromkontoIn=current_balance_in.stromkonto();
		
		current_balance_out=directchargingfactory.buildCharging();
		current_balance_out.setConnections(feedOut);
		current_balance_out.chargeAll(0);
		stromkontoOut=current_balance_out.stromkonto();
		uint256 my_reading = stromkontoDelta.sumBase();
		MPReading mpr = MPReading("0x0000000000000000000000000000000000000008");
		mpr.storeReading(my_reading);
	}
}

contract Chargable is owned {
	Stromkonto public stromkonto;
	event Charged(uint256 total_power,uint256 total_cost);
	event Charging(address meter_point);
	uint256 public total_power;
	uint256 public total_cost;
	
	function addTx(address _from,address _to, uint256 _value,uint256 _base) {}
	function addConnection(DirectConnection _connection) {}
	function setConnections(DirectConnection[] _connections) onlyOwner {}
	function chargeAll(uint256 dyn_cost) {}
	function setStromkonto(Stromkonto _stromkonto) onlyOwner {}
}

contract DirectCharging is Chargable {
	
	MPReading public reader;
	Stromkonto public stromkonto;
	DirectConnection[] public connections;
	mapping(address=>Reading) public last_reading;
	mapping(address=>address) public meter_points;
	uint256 public total_power;
	uint256 public total_cost;
	
	event Charged(uint256 total_power,uint256 total_cost);
	event Charging(address meter_point);
	struct Reading {
		uint256 time;
		uint256 power;
		
	}
	
	struct Costs {
		uint256 per_day;
		uint256 per_energy;
	}
	
	function DirectCharging(Stromkonto _stromkonto,MPReading _reader) {			
			reader=_reader;
			stromkonto=_stromkonto;
	}  
	
	function addTx(address _from,address _to, uint256 _value,uint256 _base) onlyOwner {
			stromkonto.addTx(_from,_to,_value,_base);
	}
	
	function setStromkonto(Stromkonto _stromkonto) onlyOwner {
			stromkonto=_stromkonto;
	}
	
	function addConnection(DirectConnection _connection) onlyOwner {		
		if(meter_points[_connection.meter_point()]!=address(0)) throw;
		meter_points[_connection.meter_point()]=address(_connection);		
		connections.push(_connection);				
		// we do not have to remove as this is implicit to setting costs to 0 		
	}
	
	function setConnections(DirectConnection[] _connections) onlyOwner {
			connections=_connections;
	}
	
	function chargeAll(uint256 dyn_cost) {
		for(uint i=0;i<connections.length;i++) {
								
				address meter_point = connections[i].meter_point();
				Charging(meter_point);
				var (a,b) = reader.readings(meter_point);
				
				//uint256 current_time = reader.readings(meter_point)[0];
				var current_reading = Reading(a,b);
				uint256 current_time=current_reading.time;
				uint256 current_power=current_reading.power;
				
				//Check Prerequesistes of cost calculation
				if(current_time>last_reading[meter_point].time) 
				if(current_power>last_reading[meter_point].power)
				if(last_reading[meter_point].time>0) {
					uint256 cost=0;
					uint256 delta_time=current_time-last_reading[meter_point].time;
					uint256 delta_power=current_power-last_reading[meter_point].power;
					if(dyn_cost==0) {
						cost+=delta_power*connections[i].cost_per_energy();
					} else {
						cost+=delta_power*dyn_cost;
					}
					cost+=(delta_time/86400)*connections[i].cost_per_day();
					
					//if(cost>0) {
						addTx(connections[i].from(),connections[i].to(),cost,delta_power);
						total_power+=delta_power;
						total_cost+=cost;
					//}
				}
							
				last_reading[meter_point]=current_reading;				
		}	
		Charged(total_power,total_cost);	
	}
	
}

contract AbstractDeliveryMux is owned {
	 function settleBaseDeliveries() {}
	 function handleDelivery(Delivery _delivery) {}
	 function crossBalance() onlyOwner {}
	  
}
contract DeliveryMUX is AbstractDeliveryMux {
	RoleLookup public roles;
	Delivery public base_delivery_out;
	Delivery public base_delivery_in;
	
	function DeliveryMUX(RoleLookup _roles) {
		roles=_roles;
		settleBaseDeliveries();	  
	 }

	function settleBaseDeliveries() {
	  // TODO: Requires only OWNER in Production
	  base_delivery_out=new Delivery(roles,this,5,now,now,0);
	  base_delivery_in=new Delivery(roles,this,4,now,now,0);
		
	}
	
	 function handleDelivery(Delivery _delivery) onlyOwner{

		if(_delivery.role()==base_delivery_in.role()) {
			_delivery.transferOwnership(address(base_delivery_in));
			base_delivery_in.includeDelivery(_delivery);    
		} else if(_delivery.role()==base_delivery_out.role()) {
			_delivery.transferOwnership(address(base_delivery_out));
			base_delivery_out.includeDelivery(_delivery);    
		}
	 
	}
	
	function doCrossing(Delivery _del1,Delivery _del2) internal {
		_del1.transferOwnership(address(_del2));
		_del2.includeDelivery(_del1);
	}
	
	/** Crosses In And Out BaseDelivery */
	function crossBalance() onlyOwner {
		if(base_delivery_in.deliverable_power()>base_delivery_out.deliverable_power()) {
				doCrossing(base_delivery_out,base_delivery_in);
				base_delivery_out=new Delivery(roles,this,5,now,now,0);
		} else {
				doCrossing(base_delivery_in,base_delivery_out);
				base_delivery_in=new Delivery(roles,this,4,now,now,0);
		}
	}
}

contract Provider is owned  {
	RoleLookup public roles;
	AbstractDeliveryMux public deliveryMux;
	
	TxHandler public stromkonto;
	
	mapping(address=>Billing) public billings;
	
	function Provider(RoleLookup _roles,TxHandler _stromkonto,AbstractDeliveryMux _deliveryMux) {
		stromkonto=_stromkonto;
		roles=_roles;  
		roles.setRelation(roles.roles(1),this); 
		roles.setRelation(roles.roles(2),this);
		stromkonto=_stromkonto;
		deliveryMux=_deliveryMux;
	}
   function handleDelivery(Delivery _delivery) {
	   if(_delivery.owner()!=address(this)) throw; 
	   _delivery.transferOwnership(address(deliveryMux));
	   powerToMoney(_delivery); // TODO Re-Enable!
	   deliveryMux.handleDelivery(_delivery);
	}

	function powerToMoney(Delivery _delivery) internal {
		if(address(billings[msg.sender])!=address(0)) {
			stromkonto.addTx(msg.sender,this,billings[msg.sender].calculate(_delivery),_delivery.deliverable_power());
		} // else throw ... TODO
	}
	
	function addTx(address _from,address _to, uint256 _value,uint256 _base) onlyOwner {
			stromkonto.addTx(_from,_to,_value,_base);
	}
	
	function setDeliveryMux(AbstractDeliveryMux _deliveryMux) onlyOwner {
		deliveryMux=_deliveryMux;
	}

	function approveSender(address _address,bool _approve,uint256 cost_per_day,uint256 cost_per_energy) {
		// TODO: Set onlyOwner in production
		Billing billing=new Billing(cost_per_day,cost_per_energy);
		if(_approve) {
			billing.becomeFrom();
		} 
		billings[_address]=billing;
	}
 

	
}

contract DSO is  owned {
	RoleLookup public roles;
	mapping(address=>bool) public approvedProvider;
	mapping(address=>uint256) public approvedConnections;
	function DSO(RoleLookup _roles) {
		roles=_roles;    
	}
	
	function approveConnection(address _address,uint256 _power_limit)  {
			approvedConnections[_address]=_power_limit;
			if(_power_limit>0) {
				monitor(_address,true);
			} else {
				monitor(_address,false);
			}
	}
 

	function providerAllowance(address dso,bool allow) onlyOwner {
		approvedProvider[dso]=allow;
	}
	
	DeliveryReceiver public nextReceiver;
	mapping(address=>bool) public monitored;
	
	event Process(address sender,address account,uint256 startTime,uint256 endTime,uint256 power);
	
	
	function process(Delivery _delivery) {
		if(monitored[_delivery.account()]) {
			Process(msg.sender,_delivery.account(),_delivery.deliverable_startTime(),_delivery.deliverable_endTime(),_delivery.deliverable_power());
		}
		if(address(nextReceiver)!=address(0)) nextReceiver.process(_delivery);
	}
	
	function  monitor(address _account,bool _monitor) internal {
		monitored[_account]=_monitor;    
	}
	function setNextReceiver(DeliveryReceiver _next) onlyOwner {
		nextReceiver=_next;
	}
}


contract Delivery is owned {
	RoleLookup public roles;
	address public dso;
	uint8 public role;
	
	uint256 public deliverable_startTime;
	uint256 public deliverable_endTime;
	uint256 public deliverable_power;
	address public resolution;
	address public account;
	 event Destructed(address _destruction);
	 event Included(address _address,uint256 power,uint256 startTime,uint256 endTime,uint256 role);
 
	
	function Delivery(RoleLookup _roles,address _meterpoint,uint8 _mprole,uint256 _startTime,uint256 _endTime, uint256 _power)  {
		roles=_roles;
		role=_mprole;

		deliverable_startTime=_startTime;
		deliverable_endTime=_endTime;
		deliverable_power=_power;
		
		// check sender is MPO for MP
	   // if(msg.sender!=roles.relations(_meterpoint,roles.roles(1))) throw;
		//dso=roles.relations(_meterpoint,roles.roles(2)); TODO: Check why that throws
		//if(address(0)==dso) throw;
		account=_meterpoint;    
		
	}
	
	function includeDelivery(Delivery _delivery) onlyOwner {
		if(_delivery.owner()!=address(this)) throw; // Operation only allowed if not owned by this Delivery
		
	   
		if(deliverable_startTime>_delivery.deliverable_startTime()) deliverable_startTime=_delivery.deliverable_startTime();
		if(deliverable_endTime<_delivery.deliverable_endTime()) deliverable_endTime=_delivery.deliverable_endTime();
		if(_delivery.role()==role) { 
			// add
			deliverable_power+=_delivery.deliverable_power();
		} else {
			// substract (Need to change Role, if lt 0)
			if(_delivery.deliverable_power()>deliverable_power) throw; // Not a include!
		   deliverable_power-=_delivery.deliverable_power();
		}
		Included(address(_delivery),_delivery.deliverable_power(),_delivery.deliverable_startTime(),_delivery.deliverable_endTime(),_delivery.role());
		_delivery.destructWith(this);
		
	}
   
	function destructWith(Delivery _delivery) onlyOwner { 
		
		if(address(resolution)!=0) throw;
		deliverable_power=0;
		Destructed(address(_delivery));
		
		resolution=address(_delivery);
		transferOwnership(account);
		
	}
}

contract DeliverySplit is owned {
	
	Delivery public source;
	Delivery public target_1;
	Delivery public target_2;
	
	uint256 time_to_split;
	function DeliverySplit(Delivery _sourceDelivery,uint256 _time_to_split) {
		source=_sourceDelivery;
		time_to_split = _time_to_split;
	}
	
	function doSplit()   {
		uint256 delta_time=source.deliverable_endTime()-source.deliverable_startTime();
		uint256 delta_split=time_to_split-source.deliverable_startTime();
		target_2 = new Delivery(source.roles(),source.account(),source.role(),source.deliverable_startTime(),time_to_split,(source.deliverable_power()/delta_time)*delta_split);
		target_1 = new Delivery(source.roles(),source.account(),source.role(),time_to_split,source.deliverable_endTime(),(source.deliverable_power()-target_1.deliverable_power()));
		target_1.transferOwnership(owner);
		target_2.transferOwnership(owner);
	   
		
	}
}



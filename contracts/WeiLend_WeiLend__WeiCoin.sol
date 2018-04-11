//sol Coin
// Simple minable coin.
// @authors:
//   Gav Wood <g@ethdev.com>

import "named";
import "owned";
import "coin";

contract WeiLendConfig { 
    function onNewLoan(uint lid, address addr){}
    function onContribute(uint lid, address addr, uint amount){} 
    function onRefund(uint lid, address addr, uint amount){} 
    function onPayout(uint lid, uint amount){}
	function onpayInstallment(uint lid, address addr, uint installment){}
}

contract Coin {
	function sendCoinFrom(address _from, uint _val, address _to) {}
	function sendCoin(uint _val, address _to) {}
	function coinBalance() constant returns (uint _r) {}
	function coinBalanceOf(address _a) constant returns (uint _r) {}
	function approve(address _a) {}
	function isApproved(address _proxy) constant returns (bool _r) {}
	function isApprovedFor(address _target, address _proxy) constant returns (bool _r) {}
}

contract WeiCoin is Coin, owned, WeiLendConfig {
    uint public initAmount = 0;
    uint public blockReward = 1000;
    uint public total = 0;
    uint public max = 0;
    uint public weiRatio = 0;
    uint public lid = 0;
    bool public loanStarted;
    address public weilendAddress;
    address owner;
    
	function WeiCoin(address _weilendAddress, uint _initAmount, uint _blockReward, uint _weiRatio) {
		m_balances[owner] = _initAmount;
		initAmount = _initAmount;
		owner = msg.sender;
		total += initAmount;
		blockReward = _blockReward;
		weiRatio = _weiRatio;
		weilendAddress = _weilendAddress;
		m_lastNumberMined = block.number;
	}
	
	function sendCoinFrom(address _from, uint _val, address _to) {
		if (m_balances[_from] >= _val && m_approved[_from][msg.sender]) {
			m_balances[_from] -= _val;
			m_balances[_to] += _val;
		}
	}
	
	function sendCoin(uint _val, address _to) {
		if (m_balances[msg.sender] >= _val) {
			m_balances[msg.sender] -= _val;
			m_balances[_to] += _val;
		}
	}
	
	function onNewLoan(uint _lid, address _addr) {
	    if(msg.sender != weilendAddress
	        || owner != _addr)
	        return;
	        
	    lid = _lid;
	    loanStarted = true;
	}
	
	function onContribute(uint _lid, address _addr, uint _amount) {
	    if(!loanStarted
	    || _lid != lid
	    || msg.sender != weilendAddress
	    || _amount == 0
	    || _addr == address(0))
	        return;
	        
	    m_balances[_addr] += _amount / weiRatio;
	    total += m_balances[_addr];
	}
	
	function onRefund(uint _lid, address _addr, uint _amount) {
	    if(!loanStarted
	    || _lid != lid
	    || msg.sender != weilendAddress
	    || _amount == 0
	    || _addr == address(0))
	        return;
	   
	    m_balances[_addr] -= _amount / weiRatio;
	    total -= m_balances[_addr];
	}
	
	function onpayInstallment(uint _lid, address _addr, uint _installment) {
	    if(!loanStarted
	    || _lid != lid
	    || msg.sender != weilendAddress
	    || _amount == 0
	    || _addr == address(0))
	        return;
	   
	    m_balances[_addr] -= _installment / weiRatio;
	    total -= m_balances[_addr];
	}

	function coinBalance() constant returns (uint _r) {
		return m_balances[msg.sender];
	}
	
	function coinBalanceOf(address _a) constant returns (uint _r) {
		return m_balances[_a];
	}
	
	function approve(address _a) {
		m_approved[msg.sender][_a] = true;
	}
	
	function isApproved(address _proxy) constant returns (bool _r) {
		return m_approved[msg.sender][_proxy];
	}
	
	function isApprovedFor(address _target, address _proxy) constant returns (bool _r) {
		return m_approved[_target][_proxy];
	}
	
	mapping (address => uint) m_balances;
	mapping (address => mapping (address => bool)) m_approved;
	uint m_lastNumberMined;
}

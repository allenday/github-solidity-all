/*
This Token Contract pay the holder and the team
.*/



import "./Peculium.sol";
pragma solidity ^0.4.15;

contract Stakeholder is Ownable {
	using SafeMath for uint256;


	Peculium public pecul; // token Peculium
	
	
	uint256 public decimals; // decimal of the token
	bool public initPecul; // We need first to init the Peculium Token address
	
	uint256 pay_day;
	
	//uint256 amountStakeHolder;
	
	  struct Member
	{
	   string name;
	   address eth_address;
	   uint256 amount;
	   bool pay_system; // false for classic system, true for bonus system
	   uint256 nb_payment;
	   bool approvalR;
	}

	Member[] members; 
	
	event InitializedToken(address contractToken);	
		
	//Constructor
	function Stakeholder() {
		//amountStakeHolder = amountShared;		

		members.push(Member("mohamed",0x0,10,true,0,true));
		members.push(Member("mohamedTest",0xB91528B9Ef4aB640C105cD4e948334E19DD90A4E,1000,true,0,true));
		
	}
	
	function InitPeculiumAdress(address peculAdress) public onlyOwner
	{ // We init the Peculium token address
	
		pecul = Peculium(peculAdress);
		decimals = pecul.decimals();
		initPecul = true;
		InitializedToken(peculAdress);
		pay_day = now;
		
	}


	function Addmember(string nameNew,address eth_addressNew,uint256 amountNew,bool pay_systemNew,uint256 nb_paymentNew,bool approvalRNew) public onlyOwner
	{
	members.push(Member(nameNew,eth_addressNew,amountNew,pay_systemNew,nb_paymentNew,approvalRNew));
	}
	
	
	function searchInList(address eth_to_search) internal returns(uint256) 
	{
		uint256 local;
		for(uint256 i=0; i<members.length;i++)
		{
			if(members[i].eth_address==eth_to_search)
			{
				local = i;
			}
		}
		return local;
	
	}
	
	function Remove_member(address eth_addressTo_remove) public onlyOwner
	{
		uint256 to_remove = searchInList(eth_addressTo_remove);
		delete members[to_remove];
		members[to_remove] = members[members.length];
		delete members[members.length];
		members.length--;	
	}

	function Change_approvePay(address eth_Change_Approve,bool choice) public onlyOwner
	{
		uint256 to_change = searchInList(eth_Change_Approve);
		members[to_change].approvalR = choice;
	}
	
	function Pay() onlyOwner public
	{
	require(pecul.balanceOf(this)>0);
	
		for(uint256 i=0; i<members.length;i++)
		{
			require(pay_day<now);
			require(pecul.balanceOf(this)>0);
			sendPayment(members[i]);
		}
		pay_day = now;
	}

	
	function sendPayment(Member holder) internal
	{
		require(holder.approvalR==true);
		if(holder.pay_system==false)
		{
			sendPayment_First(holder);
		}
		else if(holder.pay_system==true)
		{
			sendPayment_Second(holder);
		}
	}
	
	function sendPayment_First(Member holder) internal
	{
		if(holder.nb_payment==0)
		{
		
		uint256 first_amount = 40*holder.amount/100;
		require(pecul.balanceOf(this)>first_amount);
		pecul.transfer(holder.eth_address,first_amount);
		 
		}
		else if(holder.nb_payment>0 && holder.nb_payment<6)
		{
		
		uint256 month_amount = 10*holder.amount/100;
		require(pecul.balanceOf(this)>month_amount);
		pecul.transfer(holder.eth_address,month_amount);
		
		}
	
	
	holder.nb_payment = holder.nb_payment + 1;
	}
	
	function sendPayment_Second(Member holder) internal
	{
		if( holder.nb_payment<6)
		{
		 
		uint256 month_amount = 17*holder.amount/200;
		require(pecul.balanceOf(this)>month_amount);
		pecul.transfer(holder.eth_address,month_amount);
		
		}
		
		if(holder.nb_payment==5)
		{
		uint256 bonus_amount = 10*holder.amount/100;
		require(pecul.balanceOf(this)>bonus_amount);
		pecul.transfer(holder.eth_address,bonus_amount);
		}
	
	
	holder.nb_payment = holder.nb_payment + 1;
	}
	
	function emergency() public onlyOwner 
	{ // In case of bug or emergency, resend all tokens to initial sender
		pecul.transfer(owner,pecul.balanceOf(this));
	}
}

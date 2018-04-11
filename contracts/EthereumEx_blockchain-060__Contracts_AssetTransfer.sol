pragma solidity ^0.4.6;

contract Asset {
	string public Description;
	address public CurrentOwner;
	address NextOwner;

	function Asset(string description)
	{
		CurrentOwner = msg.sender;
		Description = description;
	}

	function TransferOwnership(address nextOwner)
	{
		if (CurrentOwner != msg.sender || NextOwner != nextOwner)
		{
			throw;
		}

		CurrentOwner = NextOwner;
		NextOwner = 0x0;
	}

	function RequstOwnership()
	{
		if (NextOwner != 0x0)
		{
			throw;
		}

		NextOwner = msg.sender;
	}
}

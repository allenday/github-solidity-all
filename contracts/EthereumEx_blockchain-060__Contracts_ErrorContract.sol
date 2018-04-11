pragma solidity ^0.4.6;

contract ErrorContract {
	address public Owner;
	address public Sender;
	event Completed(uint value); 
	event NoThrow(); 

	function ErrorContract()
	{
		Owner = tx.origin;
		Sender = msg.sender;
	}

	function ThrowError()
	{
		if (Owner != tx.origin)
		{
			throw;
		}

		NoThrow();
	}

	function AddValues(uint a, uint b)
	{
		Completed(a + b);
	}

	function ConsumeGas(uint iterations)
	{
		uint x = 0;

		for (uint i = 0; i< iterations; i++)
		{
			x += i;
		}

		Completed(x);
	}
}

contract ticker {
	uint public val;

	function tick () { val += 1;}

	function reset() { val = 0;}
}

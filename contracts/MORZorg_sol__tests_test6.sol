func counter(): int

	var i, j: int;
		k: vector[ 5 ] of int;

begin counter
	k = vector( 0, 1, 2, 3, 4 );
	foreach i in k do
		if i >= 4 then
			write "I'm done with this shit!";
			write i;
			break;
		endif;

		foreach j in k do
			if i < j then 
				break;
			endif;
			write struct( "I", i, "J", j );
		endforeach;
		write struct( "Finish innested", k[ i ] );
	endforeach;
	return i + j;
end counter


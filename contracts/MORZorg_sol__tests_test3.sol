func counter(): int

	var i, j: int;
		k: vector[ 5 ] of int;

begin counter
	k = vector( 1, 2, 3, 4, 5 );
	for i = 0 to 4 do
		if i >= 4 then
			write "I'm done with this shit!";
			write k[ i ];
			break;
		endif;

		for j = 0 to 4 do
			if i < j then 
				break;
			endif;
			write struct( "I", i, "J", j );
		endfor;
		write struct( "Finish innested", k[ i ] );
	endfor;
	return i + j;
end counter

func prog( primo: vector[1] of vector[3] of char; a: struct(a: int; b: string;); b: vector[5] of int; ): int

	type
		from_slides: vector [10] of struct( la: int; lala: vector[20] of vector [5] of real; );
	var
		fioa: int;
		struttura: struct( a: int; b: real; c: struct( a: int; b: real; c: struct( a: int; b: real; ); ); );
	const
		PEO: int = 3 + 3 + 4;

		-- I'm a comment, I'm a comment, I'm a comment.
		-- I'm a comment, I'm a comment, I'm a comment.
	func ao( sbrai: int; sbras: string; ): vector[ 4 ] of struct( a: string; )
		type
			sbrat: vector[ 2 ] of bool;
		var ri: vector[ 4 ] of struct( b: string; );
			i: int;
		const fioa: string = "pfa0o";
	begin ao
		write struttura.c.c.a;
		write primo[1][2];
		for i = 0 to 3 - sbrai do
			ri[ i + sbrai ].b = sbras;
		endfor;
		return rd ri;
	end ao

begin prog
	write a;
	write 'c';
	write '\t';
	write '\'';
	write "a\"\ts\\d";
	write ao(1, "ciao");
	while true do
		fioa = wr [ "pino" ] PEO;
		break;
	endwhile;
	return 42;
end prog


func main(): int
	type  str: vector[ 15 ] of char;
		  permutation: struct( str: str; perm: int; );
	var	  i: int;
		  p: permutation;
	const MAX_LEN: int = 15;

	func strlen( s: str; ): int
		var i: int;
	begin strlen
		write "ok";

		for i = 0 to MAX_LEN-1 do
			write i;
			write s[i];

			if s[ i ] == '\0' then
				break;
			endif;
		endfor;

		return i;
	end strlen

	func strcat( s1, s2: str; ): str
		var result, s: str;
			c: char;
	begin strcat
		if strlen( s1 ) + strlen( s2 ) <= MAX_LEN then
			foreach s in vector( s1, s2 ) do
				foreach c in s do
					result[ strlen( result ) ] = c;
				endforeach;
			endforeach;
		endif;

		return result;
	end strcat

	func factorial( i: int; ): int
		var result: int;
	begin factorial
		result = 1;
		for i = 2 to i do
			result = result * i;
		endfor;

		return result;
	end factorial

	func ceil( r: real; ): int
		var result: int;
	begin ceil
		result = toint( r );
		if toreal( result ) > r then
			result = result - 1;
		endif;

		return result;
	end ceil

	func floor( r: real; ): int
		var result: int;
	begin floor
		result = toint( r );
		if toreal( result ) < r then
			result = result + 1;
		endif;

		return result;
	end floor

	func mod( a, b: int; ): int
	begin mod
		return a - ceil( toreal( a ) / toreal( b ) ) * b;
	end mod

	func is_even( a: int; ): bool
	begin is_even
		return mod( a, 2 ) == 0;
	end is_even

	func xor( a, b: bool; ): bool
	begin xor
		return ( a and not b ) or ( not a and b );
	end xor

	func next_permutation( p: permutation; ): permutation
		var result: permutation;
			len, i: int;

		func circ_shift( s: str; a, b: int; ): str
			var i: int;
				temp: char;
		begin circ_shift
			for i = a to b-1 do
				temp = s[ i ];
				s[ i ] = s[ i + 1 ];
				s[ i + 1 ] = temp;
			endfor;

			return s;
		end circ_shift

		func flip( s: str; a, b: int; ): str
			var i: int;
				temp: char;
		begin flip
			for i = 0 to floor( toreal( b - a ) / 2.0 ) - 1 do
				temp = s[ a + i ];
				s[ a + i ] = s[ b - i ];
				s[ b - i ] = temp;
			endfor;

			return s;
		end flip

	begin next_permutation
		len = strlen( p.str );

		p.perm = p.perm + 1;
		if p.perm == factorial( len ) then
			p.perm = 0;
			p.str = flip( p.str, 0, len - 1 );

			return p;
		endif;

		for i = 2 to len do
			if mod( p.perm, factorial( i ) ) != 0 then
				p.str = circ_shift( flip( p.str, len - i + 1, len - 1 ),
									len - i,
									len - 1 );
				break;
			endif;
		endfor;

		return p;
	end next_permutation

begin main
	p.str = rd str;
	for i = 0 to factorial( strlen( p.str ) ) - 1 do
		p = wr next_permutation( p );
	endfor;
	return 0;
end main


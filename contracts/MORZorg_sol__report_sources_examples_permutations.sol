func main() : int

	type 
		pseudo_string: vector[ 15 ] of char;
		permutation: struct( str: pseudo_string; perm: int; );

	var
		i: int;
		p: permutation;
		word: pseudo_string;

	const
		MAX_LEN: int = 15;
		INTRO: string = "Insert a word:";

	func new_pseudo_string() : pseudo_string
		var
			result: pseudo_string;
			i: int;
	begin new_pseudo_string
		for i = 0 to MAX_LEN - 1 do
			result[ i ] = '\0';
		endfor;
		return result;
	end new_pseudo_string

	func strlen( s: pseudo_string; ) : int
		var i: int;
	begin strlen
		for i = 0 to MAX_LEN - 1 do
			if s[ i ] == '\0' then
				break;
			endif;
		endfor;
		return i;
	end strlen

	func strcat( s1, s2: pseudo_string; ) : pseudo_string 
		var
			result, s: pseudo_string;
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

	func strcpy( str: pseudo_string; ) : pseudo_string
		var
			result: pseudo_string;
			i: int;
	begin strcpy
		for i = 0 to strlen( str ) - 1 do
			result[ i ] = str[ i ];
		endfor;
		return result;
	end strcpy

	func recursive_factorial( number: int; ) : int
	begin recursive_factorial
		if number <= 2 then
			return number;
		endif;
		return number * recursive_factorial( number - 1 );
	end recursive_factorial

	func recursive_permutation( to_process: pseudo_string;
															base: pseudo_string;
															number: int; ) : pseudo_string
		var
			next_step, current_base, result, temp: pseudo_string;
			i, j: int;

	begin recursive_permutation
		-- Returning if i have only one char to process
		if strlen( to_process ) == 1 then 
			write vector( struct( "Recursive permutation:",
														number + 1,
														strcat( base, to_process ) ) );
			return strcat( base, to_process );
		endif;

		j = 0;
		temp = new_pseudo_string();
		while j < strlen( to_process ) do

			-- Resetting base to the argument value and resetting next_step
			current_base = strcpy( base );
			next_step = new_pseudo_string();
			-- Creating the new string to pass as argument
			for i = 0 to strlen( to_process ) - 1 do
				temp[ 0 ] = to_process[ i ];
				if i != j then
					next_step = strcat( next_step, temp );
				else
					current_base = strcat( current_base, temp );
				endif;
			endfor;

			-- Decrementing the size of the permutations
			result = recursive_permutation( next_step, current_base, number );
			number = number + recursive_factorial( strlen( next_step ) );

			j = j + 1;
		endwhile;

		-- Completly useless
		return result;
	end recursive_permutation

	func factorial( i: int; ) : int
		var result: int;
	begin factorial
		result = 1;
		for i = 2 to i do
			result = result * i;
		endfor;

		return result;
	end factorial

	func ceil( r: real; ) : int
		var result: int;
	begin ceil
		result = toint( r );
		if toreal( result ) > r then
			result = result - 1;
		endif;

		return result;
	end ceil

	func floor( r: real; ) : int
		var result: int;
	begin floor
		result = toint( r );
		if toreal( result ) < r then
			result = result + 1;
		endif;

		return result;
	end floor

	func mod( a, b: int; ) : int
	begin mod
		return a - ceil( toreal( a ) / toreal( b ) ) * b;
	end mod

	func is_even( a: int; ) : bool
	begin is_even
		return mod( a, 2 ) == 0;
	end is_even

	func xor( a, b: bool; ) : bool
	begin xor
		return ( a and not b ) or ( not a and b );
	end xor

	func next_permutation( p: permutation; ) : permutation
		var
			result: permutation;
			len, i: int;

		func circ_shift( s: pseudo_string; a, b: int; ) : pseudo_string 
			var
				i: int;
				temp: char;
		begin circ_shift
			for i = a to b-1 do
				temp = s[ i ];
				s[ i ] = s[ i + 1 ];
				s[ i + 1 ] = temp;
			endfor;
			return s;
		end circ_shift

		func flip( s: pseudo_string; a, b: int; ) : pseudo_string 
			var
				i: int;
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
	write INTRO;
	p.str = rd pseudo_string;
	word = p.str;

	write vector( struct( "Word:", word ) );

	-- Iterative permutations
	for i = 0 to factorial( strlen( p.str ) ) - 1 do
		p = wr next_permutation( p );
	endfor;

	-- Recursive permutations
	word = recursive_permutation( word, new_pseudo_string(), 0 );
	return 0;
end main


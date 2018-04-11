-- Riccardo Orizio
-- 1 Luglio 2014
-- SOL program that shows all permutations of a read set of characters.

func main() : int 
	type pseudo_string: vector [ 15 ] of char;

	var word: pseudo_string;

	const	MAX_LEN: int = 15;
			INTRO: string = "Insert a word:";

	func new_pseudo_string() : pseudo_string
		var result: pseudo_string;
			i: int;
	begin new_pseudo_string
		for i = 0 to MAX_LEN - 1 do
			result[ i ] = '\0';
		endfor;
		return result;
	end new_pseudo_string

	func strlen( str: pseudo_string; ) : int
		var i: int;
	begin strlen
		for i = 0 to MAX_LEN - 1 do
			if( str[ i ] == '\0' ) then
				break;
			endif;
		endfor;
		return i;
	end strlen

	func strcat( str1, str2: pseudo_string; ) : pseudo_string
		var i, j: int;
	begin strcat
		if strlen( str1 ) + strlen( str2 ) <= MAX_LEN then
			j = 0;
			for i = strlen( str1 ) to strlen( str1 ) + strlen( str2 ) - 1 do
				str1[ i ] = str2[ j ];
				j = j + 1;
			endfor;
		endif;

		return str1;
	end strcat

	func strcpy( str: pseudo_string; ) : pseudo_string
		var result: pseudo_string;
			i: int;
	begin strcpy
		for i = 0 to strlen( str ) - 1 do
			result[ i ] = str[ i ];
		endfor;
		return result;
	end strcpy

	func factorial( number: int; ) : int
	begin factorial
		if number <= 2 then
			return number;
		endif;

		return number * factorial( number - 1 );
	end factorial

	func permutation( to_process: pseudo_string; base: pseudo_string; number: int; ) : pseudo_string
		var next_step, current_base, result, temp: pseudo_string;
			i, j: int;
	begin permutation
		-- Returning if i have only one char to process
		if strlen( to_process ) == 1 then 
			write vector( struct( "Permutation:", number + 1, strcat( base, to_process ) ) );
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
			result = permutation( next_step, current_base, number );
			number = number + factorial( strlen( next_step ) );

			j = j + 1;
		endwhile;

		-- Completly useless
		return result;

	end permutation

begin main
	write INTRO;
	read word;

	write vector( struct( "Word:", word ) );

	word = permutation( word, new_pseudo_string(), 0 );

	return 0;

end main

func a(): int
	var   a_val: int;

	func b( c_val: int; ): int
		var	b_val: int;
			out: struct( a_val: int; );
	begin b
		out.a_val = a_val;
		write out;
		if c_val < 4 then
			return b( c_val + 1 );
		else
			return c_val;
		endif;
	end b
begin a
	a_val = 27;
	return b( 0 );
end a

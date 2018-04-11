func prog(): int

	type
		from_slides: vector [ 10 ] of struct( la: int; lala: vector[ 20 ] of vector [ 5 ] of real; );
		T2: string;
	var
		c: char;
		i: int;
		x, y, z: real;
		s: string;
		b: bool;
		r: struct( a: char; b: string; );
		v1: vector [ 5 ] of int;
		v2: vector [ 100 ] of struct( a: int; b: char; );
		out_x: real;
		out_v: vector [ 10 ] of real;

	const
		MAX: int = 100;
		name: T2 = "alpha";
		PAIR: struct( a: int; b: char; ) = struct( 25, 'c' );
		VECT: vector [ 5 ] of real = vector( 2.0, 3.12, 4.67, 1.1, 23.0 );
		MAT: vector [ 2 ] of vector [ 5 ] of real = vector( VECT, vector( x, y, z, 10.0, x+y+z ) );

	func ref(): int 
		var 
			x, y: real;
			r1, r2: struct( a: int; b: string; );
			v: vector [ 10 ] of real;

	begin ref
		x = y + toreal( 1 );
		r1 = r2;
		x = out_x + toreal( 1 );
		v = out_v;

		return 0;
	end ref

begin prog
	c = 'c';
	i = 25;
	z = 3.14;
	s = "alpha";
	b = true;

	return 42;
end prog


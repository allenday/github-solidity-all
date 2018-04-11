func dumb(): string

begin dumb
	write struct( "You entered", rd struct( age: int; random_data: vector[3] of vector[2] of struct( b:string; c:bool; ); initial: char; ) );
	return "lol";
end dumb

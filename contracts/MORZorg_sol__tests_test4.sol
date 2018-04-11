func hello_world(): int
	var
		s: int;
        i: string;

	func hello(): int

	begin hello
		return 4;
	end hello
begin hello_world
	write [ "helloworld.sbra" ] "Hello, world!";
	read [ "helloworld.sbra" ] i;
	write i;
	s = hello();
	return s;
end hello_world

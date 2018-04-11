func hello_world(): int
	var
		s: int;

	func hello(): int

	begin hello
		return 4;
	end hello
begin hello_world
	--write [ "helloworld.sbra" ] "Hello, world!";
	--read [ "helloworld.sbra" ] s;
	--write s;
	s = hello();
	return s;
end hello_world

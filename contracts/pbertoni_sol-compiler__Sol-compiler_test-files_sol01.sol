func progTest(a: int; b: string; ) : int
	type
		NUM: int; 
		LISTTYPE: vector [10] of NUM;
	var list: LISTTYPE;
		i: int;
		n: NUM;
		tmpmin, tmpmax: NUM;
	const
		MAX: int = 10;
	
	func min(a: int; b: int;): int
	begin min
		if (a < b) then
			return a;
		else
			return b;
		endif; 
	end min
	
	func max(a: int; b: int;): int
	begin max
		if (a > b) then
			return a;
		else
			return b;
		endif;
	end max
	
begin progTest
	tmpmin=0;
	tmpmax=0;
	i=0;
	write "Insert 10 positive int numbers";
	read list;
	while ( i<MAX  and list[i] > 0) do
		i=i+1;
	endwhile;
	if (i!=MAX) then
		write "Error! Negative number inserted!";
		return -1;
	endif;
	
	foreach n in list do
		tmpmin=min(tmpmin,n);
		tmpmax=max(tmpmax,n);
	endforeach;
	
	write "Elaboration complete!";
	write "min: ";
	write tmpmin;
	write "max: ";
	write "tmpmax";
		
end progTest
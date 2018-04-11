func test(): int
begin test
	write if 0 in vector( 1, 256 ) then "Wrong" else "Right" endif;
	write if 256 in vector( 1, 256 ) then "Right" else "Wrong" endif;
	return 0;
end test

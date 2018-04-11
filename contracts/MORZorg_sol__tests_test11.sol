func prova(): int
  type a: vector[ 2 ] of vector[ 3 ] of struct( a: int; b: char; c: vector[3] of int; );

begin prova
  write rd a;
  return 0;
end prova

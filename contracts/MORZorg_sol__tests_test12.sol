func file(): int
  var a: int;

begin file
  write ["pino.sbra"] 5;
  read ["pino.sbra"] a;
  write ["pina.sbra"] a;
  return a;
end file

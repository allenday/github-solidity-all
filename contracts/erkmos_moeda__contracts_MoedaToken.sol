pragma solidity ^0.4.15;
import './vendored/openzeppelin/token/StandardToken.sol';
import './vendored/openzeppelin/ownership/Ownable.sol';
import './vendored/openzeppelin/ownership/HasNoTokens.sol';
import './MigrationAgent.sol';


/// @title Moeda Loyalty Points token contract
contract MoedaToken is StandardToken, Ownable, HasNoTokens {
  string public constant name = "Moeda Loyalty Points";
  string public constant symbol = "MDA";
  uint8 public constant decimals = 18;

  // The migration agent is used to be to allow opt-in transfer of tokens to a
  // new token contract. This could be set sometime in the future if additional
  // functionality needs be added.
  MigrationAgent public migrationAgent;

  // used to ensure that a given address is an instance of a particular contract
  uint256 constant AGENT_MAGIC_ID = 0x6e538c0d750418aae4131a91e5a20363;
  uint256 public totalMigrated;

  uint constant TOKEN_MULTIPLIER = 10**uint256(decimals);
  // don't allow creation of more than this number of tokens
  uint public constant MAX_TOKENS = 20000000 * TOKEN_MULTIPLIER;

  // transfers are locked during minting
  bool public mintingFinished;

  // Log when tokens are migrated to a new contract
  event LogMigration(address indexed spender, address grantee, uint256 amount);
  event LogCreation(address indexed donor, uint256 tokensReceived);
  event LogDestruction(address indexed sender, uint256 amount);
  event LogMintingFinished();

  modifier afterMinting() {
    require(mintingFinished);
    _;
  }

  modifier canTransfer(address recipient) {
    require(mintingFinished && recipient != address(0));
    _;
  }

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /// @dev Create moeda token and assign partner allocations
  function MoedaToken() {
    // manual distribution
    issueTokens();
  }

  function issueTokens() internal {
    mint(0x2f37be861699b6127881693010596B4bDD146f5e, MAX_TOKENS);
  }

  /// @dev start a migration to a new contract
  /// @param agent address of contract handling migration
  function setMigrationAgent(address agent) external onlyOwner afterMinting {
    require(agent != address(0) && isContract(agent));
    require(MigrationAgent(agent).MIGRATE_MAGIC_ID() == AGENT_MAGIC_ID);
    require(migrationAgent == address(0));
    migrationAgent = MigrationAgent(agent);
  }

  function isContract(address addr) internal constant returns (bool) {
    uint256 size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

  /// @dev move a given amount of tokens a new contract (destroying them here)
  /// @param beneficiary address that will get tokens in new contract
  /// @param amount the number of tokens to migrate
  function migrate(address beneficiary, uint256 amount) external afterMinting {
    require(beneficiary != address(0));
    require(migrationAgent != address(0));
    require(amount > 0);

    // safemath subtraction will throw if balance < amount
    balances[msg.sender] = balances[msg.sender].sub(amount);
    totalSupply = totalSupply.sub(amount);
    totalMigrated = totalMigrated.add(amount);
    migrationAgent.migrateTo(beneficiary, amount);

    LogMigration(msg.sender, beneficiary, amount);
  }

  /// @dev destroy a given amount of tokens owned by sender
  // anyone that owns tokens can destroy them, reducing the total supply
  function burn(uint256 amount) external {
    require(amount > 0);
    balances[msg.sender] = balances[msg.sender].sub(amount);
    totalSupply = totalSupply.sub(amount);

    LogDestruction(msg.sender, amount);
  }

  /// @dev unlock transfers
  function unlock() external onlyOwner canMint {
    mintingFinished = true;
    LogMintingFinished();
  }

  /// @dev create tokens, only usable before minting has ended
  /// @param recipient address that will receive the created tokens
  /// @param amount the number of tokens to create
  function mint(address recipient, uint256 amount) internal canMint {
    require(amount > 0);
    require(totalSupply.add(amount) <= MAX_TOKENS);

    balances[recipient] = balances[recipient].add(amount);
    totalSupply = totalSupply.add(amount);

    LogCreation(recipient, amount);
  }

  // only allowed after minting has ended
  // note: transfers to null address not allowed, use burn(value)
  function transfer(address to, uint _value)
  public canTransfer(to) returns (bool)
  {
    return super.transfer(to, _value);
  }

  // only allowed after minting has ended
  // note: transfers to null address not allowed, use burn(value)
  function transferFrom(address from, address to, uint value)
  public canTransfer(to) returns (bool)
  {
    return super.transferFrom(from, to, value);
  }
}

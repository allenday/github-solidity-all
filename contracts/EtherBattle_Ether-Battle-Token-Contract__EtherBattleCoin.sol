pragma solidity ^0.4.18;


/**
 * @title Ether Battle Coin
 * @author AL_X
 * @dev The EBC ERC-X Token Contract
 */
contract EtherBattleCoin {
    string public name = "Ether Battle Coin";
    string public symbol = "EBC";
    address public selfAddress;
    address public admin;
    address[] public userList;
    uint8 public decimals = 16;
    uint24 public upperLimit = 0;
    uint256 public totalFunds;
    uint256 public totalSupply = 100000000*(10**16);
    uint256 public contractCreation;
    uint256 private decimalMultiplier = 10**16;
    uint256 private maximumPower = 0;
    bool private running;
    mapping(address => address) lastAttacker;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address => mapping (address => uint256)) cooldown;
    mapping(address => Stats) playerStats;
    
    /**
     * @notice All stats gathered in one place for easy 
     *         access and single mapping reference
     */
    struct Stats {
        uint256 ATK;
        uint256 DEF;
        uint256 ATKonCooldown;
        uint256 DEFonCooldown;
        uint256 DEFcooldown;
        uint256 ATKcooldown;
        uint256 shield;
        address randomTarget;
        bool activePlayer;
        bool isAdded;
    }
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event ATKStatus(address indexed _attacker, address indexed _defender, bool wasSuccessful, uint256 _valueFound);
    
    /**
     * @notice Ensures admin is caller
     */
    modifier isAdmin() {
        require(msg.sender == admin);
        _;
    }
    
    /**
    * @notice Re-entry protection
    */
    modifier isRunning() {
        require(!running);
        running = true;
        _;
        running = false;
    }
    
    /**
     * @notice SafeMath Library safeSub Import
     * @dev 
            Since we are dealing with a limited currency
            circulation of 10 million tokens and values
            that will not surpass the uint256 limit, only
            safeSub is required to prevent underflows.
    */
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256 z) {
        assert((z = a - b) <= a);
    }
    /**
     * @notice EBC Constructor
     * @dev 
            Normal constructor function, 94m tokens 
            on sale during the ICO, 1m tokens for 
            bounties & 5m tokens for the developers.
    */
    function EtherBattleCoin() public {
        selfAddress = this;
        admin = msg.sender;
        balances[selfAddress] = 94000000*decimalMultiplier;
        balances[msg.sender] = 6000000*decimalMultiplier;
        contractCreation = now;
    }
    
    /**
     * @notice Check the name of the token ~ ERC-20 Standard
     * @return {
                    "_name": "The token name"
                }
     */
    function name() external constant returns (string _name) {
        return name;
    }
    
    /**
     * @notice Check the symbol of the token ~ ERC-20 Standard
     * @return {
                    "_symbol": "The token symbol"
                }
     */
    function symbol() external constant returns (string _symbol) {
        return symbol;
    }
    
    /**
     * @notice Check the decimals of the token ~ ERC-20 Standard
     * @return {
                    "_decimals": "The token decimals"
                }
     */
    function decimals() external constant returns (uint8 _decimals) {
        return decimals;
    }
    
    /**
     * @notice Check the total supply of the token ~ ERC-20 Standard
     * @return {
                    "_totalSupply": "Total supply of tokens"
                }
     */
    function totalSupply() external constant returns (uint256 _totalSupply) {
        return totalSupply;
    }
    
    /**
     * @notice Query the available balance of an address ~ ERC-20 Standard
     * @param _owner The address whose balance we wish to retrieve
     * @return {
                    "balance": "Balance of the address"
                }
     */
    function balanceOf(address _owner) external constant returns (uint256 balance) {
        return balances[_owner];
    }
    /**
     * @notice Query the amount of tokens the spender address can withdraw from the owner address ~ ERC-20 Standard
     * @param _owner The address who owns the tokens
     * @param _spender The address who can withdraw the tokens
     * @return {
                    "remaining": "Remaining withdrawal amount"
                }
     */
    function allowance(address _owner, address _spender) external constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    /**
     * @notice Transfer tokens from an address to another ~ ERC-20 Standard
     * @param _from The address whose balance we will transfer
     * @param _to The recipient address
     * @param _value The amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) external {
        var _allowance = allowed[_from][_to];
        balances[_to] = balances[_to]+_value;
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][_to] = safeSub(_allowance, _value);
        Transfer(_from, _to, _value);
    }
    
    /**
     * @notice Authorize an address to retrieve funds from you ~ ERC-20 Standard
     * @dev 
            Each approval comes with a default cooldown of 30 minutes
            to prevent against the ERC-20 race attack.
     * @param _spender The address you wish to authorize
     * @param _value The amount of tokens you wish to authorize
     */
    function approve(address _spender, uint256 _value) external {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }
    
    /**
     * @notice Transfer the specified amount to the target address ~ ERC-20 Standard
     * @dev 
            A boolean is returned so that callers of the function 
            will know if their transaction went through.
     * @param _to The address you wish to send the tokens to
     * @param _value The amount of tokens you wish to send
     * @return {
                    "success": "Transaction success"
                }
     */
    function transfer(address _to, uint256 _value) external isRunning returns (bool success){
        bytes memory empty;
        if (_to == selfAddress) {
            revert();
        } else if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
    }
    
    /**
     * @notice Check whether address is a contract ~ ERC-223 Proposed Standard
     * @param _address The address to check
     * @return {
                    "is_contract": "Result of query"
                }
     */
    function isContract(address _address) internal view returns (bool is_contract) {
        uint length;
        assembly {
            length := extcodesize(_address)
        }
        return length > 0;
    }
    
    /**
     * @notice Transfer the specified amount to the target address with embedded bytes data ~ ERC-223 Proposed Standard
     * @dev Includes an extra transferToSelf function to handle Casino deposits
     * @param _to The address to transfer to
     * @param _value The amount of tokens to transfer
     * @param _data Any extra embedded data of the transaction
     * @return {
                    "success": "Transaction success"
                }
     */
    function transfer(address _to, uint256 _value, bytes _data) external isRunning returns (bool success){
        if (_to == selfAddress) {
            revert();
        } else if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }
    
    /**
     * @notice Handles transfer to an ECA (Externally Controlled Account), a normal account ~ ERC-223 Proposed Standard
     * @param _to The address to transfer to
     * @param _value The amount of tokens to transfer
     * @param _data Any extra embedded data of the transaction
     * @return {
                    "success": "Transaction success"
                }
     */
    function transferToAddress(address _to, uint256 _value, bytes _data) internal returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = balances[_to]+_value;
        Transfer(msg.sender, _to, _value);
        return true;
    }
    
    /**
     * @notice Handles transfer to a contract ~ ERC-223 Proposed Standard
     * @param _to The address to transfer to
     * @param _value The amount of tokens to transfer
     * @param _data Any extra embedded data of the transaction
     * @return {
                    "success": "Transaction success"
                }
     */
    function transferToContract(address _to, uint256 _value, bytes _data) internal returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = balances[_to]+_value;
        EtherBattleCoin rec = EtherBattleCoin(_to);
        rec.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    
    /**
     * @notice Empty tokenFallback method to ensure ERC-223 compatibility
     * @param _sender The address who sent the ERC-223 tokens
     * @param _value The amount of tokens the address sent to this contract
     * @param _data Any embedded data of the transaction
     */
    function tokenFallback(address _sender, uint256 _value, bytes _data) public {}
    
    /**
     * @notice Retrieve ERC Tokens sent to contract
     * @dev Feel free to contact us and retrieve your ERC tokens should you wish so.
     * @param _token The token contract address
     */
    function claimTokens(address _token) isAdmin external { 
        require(_token != selfAddress);
        EtherBattleCoin token = EtherBattleCoin(_token); 
        uint balance = token.balanceOf(selfAddress); 
        token.transfer(admin, balance); 
    }
    
    /**
     * @notice Fallback function 
     * @dev Triggered when Ether is sent to the contract. Adjusts price based on time.
     */
    function() payable external {
        require(msg.value > 0);
        uint256 tokenAmount;
        tokenAmount = tokenMultiplier()*msg.value;
        balances[msg.sender] += tokenAmount;
        balances[selfAddress] -= tokenAmount;
        totalFunds += msg.value;
        Transfer(selfAddress, msg.sender, tokenAmount);
        admin.transfer(msg.value);
    }
    
    /**
     * @notice Token Multiplier getter
     * @dev Allows users who invest early to get more tokens per Ether
     */
    function tokenMultiplier() public view returns (uint8) {
        if (now < contractCreation + 1 days) {
            return 20;
        } else if (now < contractCreation + 7 days) {
            return 17;
        } else if (now < contractCreation + 14 days) {
            return 15;
        } else if (now < contractCreation + 21 days) {
            return 13;
        } else {
            return 10;
        }
    }
    
    /**
     * @notice Burning function
     * @dev Burns any leftover ICO tokens to ensure a proper value is 
     *      set in the crypto market cap.
     */
    function burnLeftovers() external {
        require(contractCreation + 30 days < now && balances[selfAddress] > 0);
        totalSupply -= balances[selfAddress];
        balances[selfAddress] = 0;
    }
    /**
     * @notice Conversion function
     * @dev Converts specified amount of EBC to ATK tokens
     * @param _value Amount to convert.
     */
    function convertToATK(uint256 _value) external {
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        playerStats[msg.sender].ATK = _value;
        logIn();
        Transfer(msg.sender, 0x0, _value);
    }
    
    /**
     * @notice Conversion function
     * @dev Converts specified amount of EBC to DEF tokens
     * @param _value Amount to convert.
     */
    function convertToDEF(uint256 _value) external {
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        playerStats[msg.sender].DEF = _value;
        logIn();
        Transfer(msg.sender, 0x0, _value);
    }
    
    /**
     * @notice Platform Login Function
     * @dev Logs in user by rendering him an active player.
     */
    function logIn() internal {
        Stats storage player = playerStats[msg.sender];
        player.activePlayer = player.ATK > 0 && player.DEF > 0;
        if (!player.isAdded) {
            userList.push(msg.sender);
            player.isAdded = true;
        }
    }
    
    /**
     * @notice Platform Login Function
     * @dev Logs out user by rendering him an inactive player.
     *      Requires at least 3 days have passed since the last
     *      time the player attacked to prevent people from quitting
     *      immediately after gaining immense funds.
     */
    function logOut() external {
        Stats storage player = playerStats[msg.sender];
        require(player.ATKcooldown + 1 days < now);
        uint256 total = player.ATK + player.DEF;
        balances[msg.sender] += total;
        player.ATK = 0;
        player.DEF = 0;
        player.activePlayer = false;
        Transfer(0x0, msg.sender, total);
    }
    
    /**
     * @notice Cooldown Retrieval
     * @dev Retrives the ATK & DEF tokens currently on
     *      cooldown for the msg.sender.
     */
    function claimCooldowns() external {
        Stats storage player = playerStats[msg.sender];
        if (player.ATKonCooldown < now) {
            player.ATK += player.ATKonCooldown;
            player.ATKonCooldown = 0;
        }
        if (player.DEFonCooldown < now) {
            player.DEF += player.DEFonCooldown;
            player.DEFonCooldown = 0;
        }
    }
    
    function getPlayerStats() external view returns (uint256 _ATK, uint256 _DEF, uint256 _ATKonCooldown, uint256 _DEFonCooldown, uint256 _ATKcooldown, uint256 _DEFcooldown, uint256 _shield, address _lastAttacker, bool activePlayer) {
        Stats memory player = playerStats[msg.sender];
        if (player.ATKcooldown > now) {
            player.ATKcooldown = player.ATKcooldown - now;
        } else {
            player.ATKcooldown = 0;
        }
        if (player.DEFcooldown > now) {
            player.DEFcooldown = player.DEFcooldown - now;
        } else {
            player.DEFcooldown = 0;
        }
        return (player.ATK, player.DEF, player.ATKonCooldown, player.DEFonCooldown, player.ATKcooldown, player.DEFcooldown, player.shield, lastAttacker[msg.sender], player.activePlayer);
    }
    
    /**
     * @notice Commence an attack on a player
     * @param _target The player to attack
     * @dev Ensures that both players are active
     *      and commences an attack, rewarding the
     *      attacker with a portion of the defender's
     *      ATK tokens should he succeed
     */
    function attack(address _target) external {
        lastAttacker[_target] = msg.sender;
        Stats storage attacker = playerStats[msg.sender];
        Stats storage defender = playerStats[_target];
        require(attacker.activePlayer && defender.activePlayer && defender.shield <= now);
        if (attacker.ATK >= defender.DEF) {
            ATKStatus(msg.sender, _target, true, defender.DEF);
            attacker.ATKonCooldown += defender.DEF;
            defender.DEFonCooldown += defender.DEF;
            attacker.ATK += (defender.ATK*50/100) - defender.DEF;
            defender.DEF = 0;
            defender.ATK -= defender.ATK*50/100;
        } else {
            ATKStatus(msg.sender, _target, false, attacker.ATK);
            attacker.ATKonCooldown += attacker.ATK;
            defender.DEFonCooldown += attacker.ATK;
            defender.DEF -= attacker.ATK;
            attacker.ATK = 0;
            attacker.activePlayer = false;
        }
        if (defender.DEFcooldown <= now) {
            defender.DEFcooldown = now + 6 hours;
        }
        if (attacker.ATKcooldown <= now) {
            attacker.ATKcooldown = now + 3 hours;
        } else {
            attacker.ATKcooldown += 3 hours;
        }
        defender.shield = now + 24 hours;
        attacker.shield = 0;
    }
    
    /**
     * @notice Commence an attack on your last attacker
     * @dev Ensures that both players are active
     *      and commences an attack, rewarding the
     *      attacker with the defender's ATK tokens
     *      should he succeed
     */
    function retaliate() external {
        address _target = lastAttacker[msg.sender];
        lastAttacker[_target] = msg.sender;
        Stats storage attacker = playerStats[msg.sender];
        Stats storage defender = playerStats[_target];
        require(attacker.activePlayer && defender.activePlayer);
        if (attacker.ATK >= defender.DEF) {
            ATKStatus(msg.sender, _target, true, defender.DEF);
            attacker.ATKonCooldown += defender.DEF;
            defender.DEFonCooldown += defender.DEF;
            attacker.ATK += defender.ATK - defender.DEF;
            defender.DEF = 0;
            defender.ATK = 0;
            defender.activePlayer = false;
        } else {
            ATKStatus(msg.sender, _target, false, attacker.ATK);
            attacker.ATKonCooldown += attacker.ATK;
            defender.DEFonCooldown += attacker.ATK;
            defender.DEF -= attacker.ATK;
            attacker.ATK = 0;
            attacker.activePlayer = false;
        }
        if (defender.DEFcooldown <= now) {
            defender.DEFcooldown = now + 6 hours;
        }
        if (attacker.ATKcooldown <= now) {
            attacker.ATKcooldown = now + 3 hours;
        } else {
            attacker.ATKcooldown += 3 hours;
        }
        attacker.shield = 0;
    }
    
    /**
     * @notice Commence an attack on a random player
     * @dev Ensures that both players are active
     *      and commences an attack, rewarding the
     *      attacker with a portion of the defender's
     *      ATK tokens should he succeed
     */
    function randomAttack() external {
        Stats storage attacker = playerStats[msg.sender];
        address _target = attacker.randomTarget;
        Stats storage defender = playerStats[_target];
        lastAttacker[_target] = msg.sender;
        require(attacker.activePlayer && defender.activePlayer && defender.shield <= now && _target != 0x0);
        if (attacker.ATK >= defender.DEF) {
            ATKStatus(msg.sender, _target, true, defender.DEF);
            attacker.ATKonCooldown += defender.DEF;
            defender.DEFonCooldown += defender.DEF;
            attacker.ATK += (defender.ATK*75/100) - defender.DEF;
            defender.DEF = 0;
            defender.ATK -= defender.ATK*75/100;
        } else {
            ATKStatus(msg.sender, _target, false, attacker.ATK);
            attacker.ATKonCooldown += attacker.ATK;
            defender.DEFonCooldown += attacker.ATK;
            defender.DEF -= attacker.ATK;
            attacker.ATK = 0;
            attacker.activePlayer = false;
        }
        if (defender.DEFcooldown <= now) {
            defender.DEFcooldown = now + 6 hours;
        }
        if (attacker.ATKcooldown <= now) {
            attacker.ATKcooldown = now + 3 hours;
        } else {
            attacker.ATKcooldown += 3 hours;
        }
        defender.shield = now + 12 hours;
        attacker.shield = 0;
        attacker.randomTarget = 0x0;
    }
    
    /**
     * @notice Assign Random Target
     * @dev The random attack process is split 
     *      into two parts to ensure scalability.
     */
    function randomTargetAssign() external {
        uint n = 0;
        raiseLimit();
        for (uint i = 0; i < userList.length; i++) {
            if (uint(block.blockhash(block.number-i-1))%2==0) {
                n += 2**i;
            }
        }
        assert(n < userList.length);
        assert(userList[n] != msg.sender);
        Stats storage user = playerStats[msg.sender];
        user.randomTarget = userList[n];
    }
    
    /**
     * @notice Recursive Upper Blockhash Limit Adjuster Function
     */
    function raiseLimit() public {
        if (2**upperLimit < userList.length) {
            upperLimit += 1;
            raiseLimit();
        }
    }
}

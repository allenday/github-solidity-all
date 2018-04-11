/// @title Tru Upgradeable Token
/// @notice A token upgrade mechanism where users can opt-in amount of tokens to the next smart contract revision.
/// @dev This Smart Contract is based upon UpgradeableToken by TokenMarket Ltd. The original source can be found
/// at https://raw.githubusercontent.com/TokenMarketNet/ico/master/contracts/UpgradeableToken.sol
/// It has been updated for Tru Ltd's purposes in November 2017 and compiles with solidity 0.4.18's syntax
/// @author Ian Bray, Tru Ltd/Original: TokenMarket Ltd
pragma solidity 0.4.18;

import "./SafeMath.sol";
import "./StandardToken.sol";
import "./UpgradeAgent.sol";


contract TruUpgradeableToken is StandardToken {

    using SafeMath for uint256;
    using SafeMath for uint;

    /// @notice Contract / person who can set the upgrade path.
    address public upgradeMaster;

    /// @notice The Contract that the target will be upgraded to
    UpgradeAgent public upgradeAgent;

    /// @notice Total Number of upgraded tokens
    uint256 public totalUpgraded;

    /// @notice Whether the Contract is upgradeable
    bool private isUpgradeable = true;

    /**
     * Upgrade states.
     *
     * - NotAllowed: The child contract has not reached a condition where the upgrade can begin
     * - WaitingForAgent: Token allows upgrade, but we don't have a new agent yet
     * - ReadyToUpgrade: The agent is set, but not a single token has been upgraded yet
     * - Upgrading: Upgrade agent is set and the balance holders can upgrade their tokens
     *
    */
    enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

    /// @notice Event to notify when a token holder upgrades their tokens
    /// @param to Destination address of upgraded tokens (should always be upgradeAgent)
    /// @param upgradeValue Number of tokens being upgraded
    event Upgrade(address indexed from, 
        address indexed to, 
        uint256 upgradeValue);

    /// @notice Event to notify when an upgradeAgent is set
    /// @param agent upgradeAgent address
    /// @param executor Address which set the upgradeAgent
    event UpgradeAgentSet(address indexed agent, 
        address indexed executor);

    /// @notice Event to notify the new total number of tokens that have been
    /// @param originalBalance Balance of Upgrade Tokens before
    /// @param newBalance Balance of Upgrade Tokens after
    /// @param executor AAddress that executed the token upgrade
    event NewUpgradedAmount(uint256 originalBalance, 
        uint256 newBalance, 
        address indexed executor);
    
    /// @notice Modifier to only allow the Upgrade Master to execute the function
    modifier onlyUpgradeMaster() {
        require(msg.sender == upgradeMaster);
        _;
    }

    /**
     * Constructor
    */
    function TruUpgradeableToken(address _upgradeMaster) public {

        require(_upgradeMaster != address(0));
        upgradeMaster = _upgradeMaster;
    }

    /**
     * Allow the token holder to upgrade some of their tokens to a new contract.
    */
    function upgrade(uint256 _value) public {
        UpgradeState state = getUpgradeState();
        require((state == UpgradeState.ReadyToUpgrade) || (state == UpgradeState.Upgrading));
        require(_value > 0);
        require(balances[msg.sender] >= _value);

        uint256 upgradedAmount = totalUpgraded.add(_value);

        uint256 senderBalance = balances[msg.sender];
        uint256 newSenderBalance = senderBalance.sub(_value);      
        uint256 newTotalSupply = totalSupply.sub(_value);
        balances[msg.sender] = newSenderBalance;
        totalSupply = newTotalSupply;        
        NewUpgradedAmount(totalUpgraded, newTotalSupply, msg.sender);
        totalUpgraded = upgradedAmount;
        // Upgrade agent reissues the tokens
        upgradeAgent.upgradeFrom(msg.sender, _value);
        Upgrade(msg.sender, upgradeAgent, _value);
    }

    /**
     * Set an upgrade agent that handles
    */
    function setUpgradeAgent(address _agent) public onlyUpgradeMaster {
        require(_agent != address(0));
        require(canUpgrade());
        require(getUpgradeState() != UpgradeState.Upgrading);

        UpgradeAgent newUAgent = UpgradeAgent(_agent);

        require(newUAgent.isUpgradeAgent());
        require(newUAgent.originalSupply() == totalSupply);

        UpgradeAgentSet(upgradeAgent, msg.sender);

        upgradeAgent = newUAgent;
    }

    /**
     * Get the state of the token upgrade.
    */
    function getUpgradeState() public constant returns(UpgradeState) {
        if (!canUpgrade())
            return UpgradeState.NotAllowed;
        else if (upgradeAgent == address(0))
            return UpgradeState.WaitingForAgent;
        else if (totalUpgraded == 0)
            return UpgradeState.ReadyToUpgrade;
        else 
            return UpgradeState.Upgrading;
    }

    /**
     * Change the upgrade master.
     *
     * This allows us to set a new owner for the upgrade mechanism.
    */
    function setUpgradeMaster(address _master) public onlyUpgradeMaster {
        require(_master != address(0));
        upgradeMaster = _master;
    }

    /**
     * Child contract can enable to provide the condition when the upgrade can begun.
    */
    function canUpgrade() public constant returns(bool) {
        return isUpgradeable;
    }
}

/// @title Tru Reputation Token
/// @notice Tru Reputation Protocol ERC20 compliant Token
/// @author Ian Bray
pragma solidity 0.4.18;

import "./supporting/SafeMath.sol";
import "./supporting/TruMintableToken.sol";
import "./supporting/TruUpgradeableToken.sol";


contract TruReputationToken is TruMintableToken, TruUpgradeableToken {

    using SafeMath for uint256;
    using SafeMath for uint;

    /// @notice number of decimals for the Token - 18
    uint8 public constant decimals = 18;

    /// @notice name of the Token - Tru Reputation Token
    string public constant name = "Tru Reputation Token";

    /// @notice Symbol of the Token - TRU
    string public constant symbol = "TRU";

    /// @notice Address of Tru Advisory Board
    address public execBoard = 0x0;

    /// @notice Event to notify when the execBoard address changes
    /// @param oldAddress old address of the execBoard
    /// @param newAddress old address of the execBoard
    /// @param executor Account that executed the change
    event BoardAddressChanged(address indexed oldAddress, 
        address indexed newAddress, 
        address indexed executor);

    /// @notice Modifier to only allow the Tru Advisory Board MultiSig Wallet to execute the function
    modifier onlyExecBoard() {
        require(msg.sender == execBoard);
        _;
    }

    /// @notice Constructor for TruReputationToken Contract
    function TruReputationToken() public TruUpgradeableToken(msg.sender) {
        execBoard = msg.sender;
        BoardAddressChanged(0x0, msg.sender, msg.sender);
    }
    
    /// @notice Function to change the address of the Tru Advisory Board
    /// @dev Can only be executed by the Current Tru Advisory Board
    /// @param _newAddress New address of the Tru Advisory Board
    function changeBoardAddress(address _newAddress) public onlyExecBoard {
        require(_newAddress != address(0));
        require(_newAddress != execBoard);
        address oldAddress = execBoard;
        execBoard = _newAddress;
        BoardAddressChanged(oldAddress, _newAddress, msg.sender);
    }

    /// @notice Function to check if this token contract can be upgraded
    function canUpgrade() public constant returns(bool) {
        return released && super.canUpgrade();
    }

    /// @notice Function to set Upgrade Master of this contract
    /// @dev can only be set by current contract owner
    /// @param _master Address of the Upgrade Master contract
    function setUpgradeMaster(address _master) public onlyOwner {
        super.setUpgradeMaster(_master);
    }
}
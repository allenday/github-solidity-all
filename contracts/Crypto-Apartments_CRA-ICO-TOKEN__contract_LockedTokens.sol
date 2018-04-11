pragma solidity ^0.4.15;


import "./ERC20Interface.sol";
import "./SafeMath.sol";
import "./CRATokenConfig.sol";

contract LockedTokens is CRATokenConfig {
    using SafeMath for uint;
    uint public constant TOKENS_LOCKED_1Y_TOTAL = 4000000 * DECIMALSFACTOR;
    uint public constant TOKENS_LOCKED_2Y_TOTAL = 6000000 * DECIMALSFACTOR;
    address public TRANCHE2_ACCOUNT = 0x8060B83F84CfE5606d9ECcF61A4d237F489Bfd25;
    uint public totalSupplyLocked1Y;
    uint public totalSupplyLocked2Y;
    mapping (address => uint) public balancesLocked1Y;
    mapping (address => uint) public balancesLocked2Y;
    ERC20Interface public tokenContract;
    function LockedTokens(address _tokenContract) {
        tokenContract = ERC20Interface(_tokenContract);
        // --- 1y locked tokens ---
        // Fonders
        add1Y(0x586A518C0576D21738F40061cFF67F427fAb0a3f, 4000000 * DECIMALSFACTOR);
        // Confirm 1Y totals
        assert(totalSupplyLocked1Y == TOKENS_LOCKED_1Y_TOTAL);
        // --- 2y locked tokens ---
        // Fonders
        add2Y(0xb7c20559448e012BEB0aAa96Ae3028886F0ed466, 6000000 * DECIMALSFACTOR);
        // Confirm 2Y totals
        assert(totalSupplyLocked2Y == TOKENS_LOCKED_2Y_TOTAL);
    }
    function addRemainingTokens() {
        // Only the crowdsale contract can call this function
        require(msg.sender == address(tokenContract));
        // Total tokens to be created
        uint remainingTokens = TOKENS_TOTAL;
        // Minus precommitments and public crowdsale tokens
        remainingTokens = remainingTokens.sub(tokenContract.totalSupply());
        // Minus 1y locked tokens
        remainingTokens = remainingTokens.sub(totalSupplyLocked1Y);
        // Minus 2y locked tokens
        remainingTokens = remainingTokens.sub(totalSupplyLocked2Y);
        // Unsold tranche1 and tranche2 tokens to be locked for 1y 
        add1Y(TRANCHE2_ACCOUNT, remainingTokens);
    }
    function add1Y(address account, uint value) private {
        balancesLocked1Y[account] = balancesLocked1Y[account].add(value);
        totalSupplyLocked1Y = totalSupplyLocked1Y.add(value);
    }
    function add2Y(address account, uint value) private {
        balancesLocked2Y[account] = balancesLocked2Y[account].add(value);
        totalSupplyLocked2Y = totalSupplyLocked2Y.add(value);
    }
    function balanceOfLocked1Y(address account) constant returns (uint balance) {
        return balancesLocked1Y[account];
    }
    function balanceOfLocked2Y(address account) constant returns (uint balance) {
        return balancesLocked2Y[account];
    }
    function balanceOfLocked(address account) constant returns (uint balance) {
        return balancesLocked1Y[account].add(balancesLocked2Y[account]);
    }
    function totalSupplyLocked() constant returns (uint) {
        return totalSupplyLocked1Y + totalSupplyLocked2Y;
    }
    function unlock1Y() {
        require(now >= LOCKED_1Y_DATE);
        uint amount = balancesLocked1Y[msg.sender];
        require(amount > 0);
        balancesLocked1Y[msg.sender] = 0;
        totalSupplyLocked1Y = totalSupplyLocked1Y.sub(amount);
        if (!tokenContract.transfer(msg.sender, amount)) throw;
    }
    function unlock2Y() {
        require(now >= LOCKED_2Y_DATE);
        uint amount = balancesLocked2Y[msg.sender];
        require(amount > 0);
        balancesLocked2Y[msg.sender] = 0;
        totalSupplyLocked2Y = totalSupplyLocked2Y.sub(amount);
        if (!tokenContract.transfer(msg.sender, amount)) throw;
    }
}
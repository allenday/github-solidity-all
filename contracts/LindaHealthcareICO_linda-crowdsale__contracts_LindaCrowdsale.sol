pragma solidity ^0.4.11;

import "./zeppelin/crowdsale/CappedCrowdsale.sol";
import "./zeppelin/crowdsale/RefundableCrowdsale.sol";
import "./zeppelin/token/TokenTimelock.sol";
import "./LindaToken.sol";

contract LindaCrowdsale is CappedCrowdsale, RefundableCrowdsale, Pausable {

    // time for tokens to be locked in their respective vaults

    uint64 public unsoldLockTime;
    uint64 public teamLockTime;

    // address where team funds are collected
    address public teamWallet;
    address public tokenOwner;

    // how many token in percentage will correspond to team and sale
    uint256 public teamPercentage = 20;
    uint256 public salePercentage = 45;
    uint256 public ecosystemPercentage = 31;

    uint256 public maximumSaleTokenSupply;
    uint256 public teamTokens;
    uint256 public unsoldTokens;
    uint256 public ecosystemTokens;


    TokenTimelock public teamVault;
    TokenTimelock public unsoldVault;


    function LindaCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _goal, uint256 _cap, address _wallet, address _teamWallet, address _tokenAddress, address _tokenOwner, uint64 _teamLockTime, uint64 _unsoldLockTime)
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goal)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    {
        //As goal needs to be met for a successful crowdsale
        //the value needs to less or equal than a cap which is limit for accepted funds
        require(_goal <= _cap);
        require(_teamWallet != 0x0);
        require(_tokenAddress != 0x0);
        require(_tokenOwner != 0x0);
        require(_teamLockTime > 0);
        require(_unsoldLockTime > 0);

        maximumSaleTokenSupply = _cap.mul(_rate);
        teamWallet = _teamWallet;
        wallet = _wallet;
        tokenOwner = _tokenOwner;
        teamLockTime = _teamLockTime;
        unsoldLockTime = _unsoldLockTime;
        token = createTokenContract(_tokenAddress);

    }

    function createTokenContract(address tokenAddress) internal returns (MintableToken) {
        return LindaToken(tokenAddress);
    }

    function finalization() internal {

        if (goalReached()) {
        // freeze tokens only if goal is reached
        teamVault = new TokenTimelock(token, teamWallet, uint64(now) + teamLockTime);
        unsoldVault = new TokenTimelock(token, wallet, uint64(now) + unsoldLockTime);

        teamTokens = (maximumSaleTokenSupply.mul(teamPercentage)).div(salePercentage);
        unsoldTokens = maximumSaleTokenSupply.sub(token.totalSupply());
        ecosystemTokens = (maximumSaleTokenSupply.mul(ecosystemPercentage)).div(salePercentage);

        token.mint(teamVault, teamTokens);
        token.mint(unsoldVault, unsoldTokens);
        token.mint(wallet, ecosystemTokens);
        }

        token.finishMinting();
        token.transferOwnership(tokenOwner);
        super.finalization();

    }

    function buyTokens(address beneficiary) public payable whenNotPaused {
    super.buyTokens(beneficiary);
    }

    // @return true if crowdsale event has started
    function hasStarted() public constant returns (bool) {
        return now > startTime;
    }



}
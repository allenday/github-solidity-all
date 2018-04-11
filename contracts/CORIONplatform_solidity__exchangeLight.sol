/*
    exchangeLight.sol
    1.1.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.15;

import "./owned.sol";
import "./safeMath.sol";
import "./token.sol";

contract exchange is owned, safeMath {
    /* Variables */
    uint256 public exchangeRate;
    uint256 public exchangeRateM = 1e3;
    uint256 public maxReceiveEther = 0.3 ether;
    uint256 public exchangeRateShift = 120; // +20%
    address public exchangeRateManager;
    address public foundation = 0xbed261d8da9f13dfd10bf568ea22d353c15737da;
    address public CORAddress;
    /* Constructor */
    function exchange(address _CORAddress, address _exchangeRateManager, uint256 _exchangeRate, uint256 _exchangeRateShift) payable {
        require( _CORAddress != 0x00 && _exchangeRateManager != 0x00 && _exchangeRate > 0 );
        CORAddress = _CORAddress;
        exchangeRateManager = _exchangeRateManager;
        exchangeRate = _exchangeRate;
        exchangeRateShift = _exchangeRateShift;
        owner = msg.sender;
    }
    /* Fallback */
    function () payable {}
    /* Externals */
    function receiveToken(address sender, uint256 amount, bytes data) external returns (bool success, uint256 sendBack) {
        require( msg.sender == CORAddress );
        require( amount > 0 );
        require( sender.balance <= maxReceiveEther );
        require( amount <= calcETCtoCOR(maxReceiveEther*2) );
        require( sender.call.value(calcCORtoETC(amount))() );
        return ( true, 0 );
    }
    function approvedToken(address addr, uint256 amount, bytes data) external returns (bool) { revert(); }
    function getEther() external {
        require( foundation.send(this.balance) );
    }  
    function getCOR() external {
        require( token(CORAddress).transfer(foundation, token(CORAddress).balanceOf(address(this)) ) );
    }
    function destroy() external {
        require( isOwner() );
        require( token(CORAddress).transfer(foundation, token(CORAddress).balanceOf(address(this)) ) );
        suicide( foundation );
    }
    function setCORAddress(address newCORAddress) external {
        require( isOwner() );
        CORAddress = newCORAddress;
    }
    function setMaxReceiveEther(uint256 amount) external {
        require( isOwner() );
        maxReceiveEther = amount;
    }
    function setFoundationAddress(address addr) external {
        require( isOwner() );
        foundation = addr;
    }
    function setExchangeRateShift(uint256 value) external {
        require( isOwner() );
        exchangeRateShift = value;
    }
    function setExchangeRate(uint256 newExchangeRate) external {
        require( msg.sender == exchangeRateManager );
        exchangeRate = newExchangeRate;
    }
    /* Constants */
    function calcCORtoETC(uint256 cor) public constant returns(uint256 etc) {
        return safeMul(safeMul(cor, 1e12), exchangeRateM) / ( safeMul(exchangeRate, exchangeRateShift) / 100 ) ; 
    }
    function calcETCtoCOR(uint256 etc) public constant returns(uint256 cor) {
        return safeMul(safeMul(exchangeRate, exchangeRateShift) / 100, etc) / 1e12 / exchangeRateM;
    }
}

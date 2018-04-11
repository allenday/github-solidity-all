pragma solidity ^0.4.11;

/**
* Copyright 2017 Veterapreneur
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
* documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
* rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all copies or substantial portions of
* the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
* WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
* OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*
*/

/**
 * Math operations with safety checks
 */
library SafeMath {
    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}

contract owned {

    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
}

contract token {
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function burn(uint256 value) returns(bool success);
}


contract VeteranCoinFree is owned {

    using SafeMath for uint256;

    uint  public tokensGiven;
    uint  public startDate;
    uint  public endDate;
    bool  giveAwayOpen;
    token tokenReward;

    event GiveAwayClosed();
    event OpenGiveAway();
    event FundTransfer(address _backer, uint _amount, bool _isContribution);
    event FreeTokens(address _backer, uint _tokenAmt);
    event Refunded(address _beneficiary, uint _depositedValue);
    event BurnedExcessTokens(address _beneficiary, uint _amountBurned);

    mapping(address => uint256)  balances;

    modifier releaseTheHounds(){ if (now >= startDate) _;}
    modifier isGiveAwayOpen(){ if (giveAwayOpen) _;}

    function VeteranCoinFree(token _addressOfTokenReward){
        startDate = now;
        endDate = now + 1 years;
        tokenReward = _addressOfTokenReward;
        tokensGiven = 0;
        giveAwayOpen = false;
    }

    /**
    *  @dev donations, no tokens only thanks!
    */
    function() payable {
        donation(msg.sender);
    }

    /**
    *  @dev donations, no tokens only thanks!
    */
    function donation(address grantor) public payable {
        require (grantor != 0x0);
        balances[grantor] = balances[grantor].add(msg.value);
        FundTransfer(msg.sender, msg.value, true);
    }

    /**
    *
    *   @dev Everyone can get 10 free tokens per call, enjoy
    */
    function tokenGiveAway() public releaseTheHounds isGiveAwayOpen{
        uint256 tokens = 10 * 1 ether;
        tokensGiven = tokensGiven.add(tokens);
        tokenReward.transfer(msg.sender, tokens);
        checkGivenAway();
    }

    /**
     *
     *  @dev balances of wei sent this contract currently holds
     *  @param _beneficiary how much wei this address sent to contract
     */
    function balanceOf(address _beneficiary) public constant returns (uint256 balance){
        return balances[_beneficiary];
    }

    /**
    *   @dev refund any of the donations made to us
    *
    */
    function refundDonation(address _beneficiary) public onlyOwner{
        uint256 depositedValue = balances[_beneficiary];
        require(depositedValue > 0);
        balances[_beneficiary] = 0;
        _beneficiary.transfer(depositedValue);
        Refunded(_beneficiary, depositedValue);
    }

    /**
    *
    *   @dev close the give away when the MVP is nigh, or we are out of tokens!
    */
    function closeGiveAway() public onlyOwner{
        giveAwayOpen = false;
        GiveAwayClosed();
    }

    function openGiveAway() public onlyOwner{
        giveAwayOpen = true;
        OpenGiveAway();
    }

    /**
     * @dev when token's sold = 0, it's over
     *
     */
    function checkGivenAway() internal {
        if(tokenReward.balanceOf(this) == 0){
            giveAwayOpen = false;
            GiveAwayClosed();
        }
    }

    /**
     * @dev owner can safely withdraw contract value
     */
    function safeWithdrawal() public onlyOwner{
        uint256 balance = this.balance;
        if(owner.send(balance)){
            FundTransfer(owner,balance,false);
        }
    }

    // @return true if crowdsale is still going on
    function giveAwayInProgress() public constant returns (bool) {
        return giveAwayOpen;
    }

    /**
     * @dev auto burn the tokens
     *
     */
    function autoBurn() public onlyOwner{
        giveAwayOpen = false;
        uint256 burnPile = tokenReward.balanceOf(this);
        if(burnPile > 0){
            tokenReward.burn(burnPile);
            BurnedExcessTokens(owner, burnPile);
        }
    }

}

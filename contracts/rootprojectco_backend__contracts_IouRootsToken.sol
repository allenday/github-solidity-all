pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
    * @dev Function to mint tokens
    * @param _to The address that will recieve the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) onlyOwner returns (bool) {
        return mintInternal(_to, _amount);
    }

    /**
    * @dev Function to stop minting new tokens.
    * @return True if the operation was successful.
    */
    function finishMinting() onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

    function mintInternal(address _to, uint256 _amount) internal canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }
}


contract IouRootsToken is MintableToken {

    string public name;
    
    string public symbol;
    
    uint8 public decimals;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint256 public rate;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    // This is not a ROOT token.
    // This token is used for the preallocation of the ROOT token, that will be issued later.
    // Only Owner can transfer balances and mint ROOTS without payment.
    // Everybody can buy IOU ROOT token by sending some amount of ETH to the contract.
    // Amount of purchased ROOTS determined by the Rate.
    // All ETH are going to Wallet address.
    // Owner can finalize the contract by `finishMinting` transaction
    function IouRootsToken(
        uint256 _rate,
        address _wallet,
        string _name,
        string _symbol,
        uint8 _decimals
    ) {
        require(_rate > 0);
        require(_wallet != 0x0);

        rate = _rate;
        wallet = _wallet;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function transfer(address _to, uint _value) onlyOwner returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) onlyOwner returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function () payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) payable {
        require(beneficiary != 0x0);
        require(msg.value > 0);

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

        mintInternal(beneficiary, tokens);
        TokenPurchase(
            msg.sender, 
            beneficiary, 
            weiAmount, 
            tokens
        );

        forwardFunds();
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

}

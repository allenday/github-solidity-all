pragma solidity ^0.4.15;
//
// https://ethereum.github.io/browser-solidity/
// https://github.com/OpenZeppelin/zeppelin-solidity/tree/master/contracts/token
// 
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/MintableToken.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/BurnableToken.sol";

contract FooStdToken is StandardToken {

  string public constant name = "FooToken";
  string public constant symbol = "FOO";
  uint256 public constant decimals = 3;

  uint256 public constant INITIAL_SUPPLY = 21000000;

  /**
   * @dev Contructor that gives msg.sender all of existing tokens. 
   */
  function FooStdToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}

// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/MintableToken.sol
contract FooMintableToken is MintableToken {

  string public constant name = "FooMintableToken";
  string public constant symbol = "FOM";
  uint256 public constant decimals = 6;

  uint256 public constant INITIAL_SUPPLY = 21000000;

  /**
   * @dev Contructor that gives msg.sender all of existing tokens. 
   */
  function FooMintableToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}

// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/BurnableToken.sol
contract FooBurnableToken is BurnableToken {

  string public constant name = "FooToken";
  string public constant symbol = "FOO";
  uint256 public constant decimals = 6;

  uint256 public constant INITIAL_SUPPLY = 21000000;

  /**
   * @dev Contructor that gives msg.sender all of existing tokens. 
   */
  function FooBurnableToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}

contract TestZepplinToken{
    
    // https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/MintableToken.sol
    function testMintableToken(){
        MintableToken token = new FooMintableToken();
        var result = token.mint(0xdeed,199000);
        require(result == true);
        require(token.balanceOf(0xdeed) == 199000);
        require(token.mintingFinished() == false);
        require(token.finishMinting());
        require(token.mintingFinished());
    }
    
     function testMintInvalid(){
        MintableToken token = new FooMintableToken();
        require(token.finishMinting());
        require(token.mintingFinished());
        var result = token.mint(0xdeed,199000);
        require(result == false);
    }   
}

// differnce ?
// Build-a-Coin Cryptocurrency Creator http://build-a-co.in/
// How To Create Your Own Cryptocurrency https://www.fastcompany.com/3025700/how-to-create-your-own-cryptocurrency
// Build-a-Coin Cryptocurrency Creator | Hacker News https://news.ycombinator.com/item?id=15077117
// CryptoAsset Market Capitalizations https://coinmarketcap.com/assets/

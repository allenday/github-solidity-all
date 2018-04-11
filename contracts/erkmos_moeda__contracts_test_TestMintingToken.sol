pragma solidity ^0.4.15;
import '../MoedaToken.sol';


contract TestMintingToken is MoedaToken {
  function create(address recipient, uint256 amount) public {
    super.mint(recipient, amount);
  }

  function issueTokens() internal {
    super.mint(0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC, 1);
  }
}

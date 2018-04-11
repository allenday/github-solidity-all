pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
// import "../etc/CinderToken.sol";
import "../contracts/CinderTokenSale.sol";

contract TestCinderTokenSale {

  // function testSaleHasOwnerOnCreation() {
  //   CinderTokenSale sale = CinderTokenSale(DeployedAddresses.CinderTokenSale());

  //   address expected = msg.sender;

  //   Assert.equal(sale.owner(), expected, "should have owner");
  // }

  // function testHasCinderToken() {
  //   CinderTokenSale sale = CinderTokenSale(DeployedAddresses.CinderTokenSale());

  //   CinderToken token = CinderToken(DeployedAddresses.CinderToken());

  //   Assert.equal(sale.token(), token, "should have CinderToken token");
  // }

  // function testInitialBalanceUsingNewContract() {
  //   CinderToken meta = new CinderToken();

  //   uint256 expected = ((1 * (10 ** 9) * (10 ** 18)) * (100-60))/100;

  //   Assert.equal(meta.balanceOf(msg.sender), expected, "Owner should have 10000 CinderToken initially");
  // }


}

// contract TestCinderTokenSale {
//     using SafeMath for uint256;

//     DistributionSale public sale;

//     uint64 constant SUPPLY_FLOOR = 1 * (10 ** 3); // 1 thousand whole tokens
//     uint64 constant SUPPLY_CEILING = 6174; // 1 million whole tokens

//     uint256 constant INITIAL_RATE = 1 * (10 ** 18); // in Wei
//     uint64 constant ALLOCATION = 10; // in hundred percent examples: [ 0.02%, 4.00%, 99.99% ]

//     function BlingTokenSale() {
//         owned();
//         sale = new CinderTokenSale(uint256(SUPPLY_FLOOR), uint256(SUPPLY_CEILING), INITIAL_RATE, msg.sender, uint256(ALLOCATION));
//     }
// }
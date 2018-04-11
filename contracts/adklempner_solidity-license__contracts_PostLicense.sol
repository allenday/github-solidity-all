pragma solidity ^0.4.11;

import './zeppelin/token/ERC20.sol';
import './zeppelin/ownership/Ownable.sol';
import './zeppelin/payment/PullPayment.sol';
import './Licensed.sol';

contract PostLicense is Licensed, Ownable, PullPayment {

  mapping(address => Token) tokens;
  mapping(address => License) licenses;
  uint256 licensePriceETH;
  uint256 licenseReimbursementETH;

  struct Token {
    bool valid;
    uint256 price;
    uint256 reimbursement;
  }

  struct License {
    bool valid;
    address token; //0x0 = eth
  }

  function PostLicense() {
    licensePriceETH = 0.1 ether;
    licenseReimbursementETH = 0.08 ether;
  }

  function buyLicenseForERC20(address token) {
    require(!holdsValidLicense(msg.sender));
    require(isAcceptedToken(token));
    require(ERC20(token).transferFrom(msg.sender, this, getLicensePrice(token)));
    licenses[msg.sender].valid = true;
    licenses[msg.sender].token = token;
  }

  function buyLicenseForETH() payable {
    require(!holdsValidLicense(msg.sender));
    require(msg.value == getLicensePrice());
    licenses[msg.sender].valid = true;
    licenses[msg.sender].token = 0x0;
  }

  function sellLicense() {
    require(holdsValidLicense(msg.sender));
    if(licenses[msg.sender].token != 0x0) {
      require(ERC20(licenses[msg.sender].token).transfer(msg.sender, getLicenseReimbursement(licenses[msg.sender].token)));
    } else {
      asyncSend(msg.sender, getLicenseReimbursement());
    }
    licenses[msg.sender].valid = false;
  }

  function addAcceptedToken(address token, uint256 price, uint256 reimbursement) onlyOwner {
    tokens[token].valid = true;
    tokens[token].price = price;
    tokens[token].reimbursement = reimbursement;
  }

  function removeAcceptedToken(address token) onlyOwner {
    tokens[token].valid = false;
  }

  function getLicenseReimbursement(address token) returns (uint256) {
    return tokens[token].reimbursement;
  }

  function getLicenseReimbursement() constant returns (uint256) {
    return licenseReimbursementETH;
  }

  function holdsValidLicense(address holder) constant returns (bool) {
    return licenses[holder].valid;
  }

  function getLicensePrice(address token) constant returns (uint256) {
    return tokens[token].price;
  }

  function getLicensePrice() constant returns (uint256) {
    return licensePriceETH;
  }

  function isAcceptedToken(address token) constant returns (bool) {
    return tokens[token].valid;
  }

}

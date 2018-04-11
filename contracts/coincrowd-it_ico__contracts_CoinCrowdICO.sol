pragma solidity ^0.4.15;

import "zeppelin/contracts/math/SafeMath.sol";
import "zeppelin/ownership/Ownable.sol";
import "./Ambassador.sol";
import "./Constants.sol";
import {CoinCrowdToken} from "./CoinCrowdToken.sol";

contract CoinCrowdICO is Constants, Ownable {
    using SafeMath for uint256;

    CoinCrowdToken public tokenContract;

    uint256 public tokenValue;  // 1 XCC in wei

    uint256 public endTime;  // seconds from 1970-01-01T00:00:00Z

    // map ambassador contract to ambassador
    mapping(address => address) public ambassadors;

    // map ambassadors to token collected
    mapping(address => uint256) public communityTokensOf;

    address[] public ambassadorContracts;

    function ambassadorsNumber() public constant returns (uint256) {
        return ambassadorContracts.length;
    }

    struct Purchase {
        uint256 token;
        uint256 date;
        address ambassador;
    }

    mapping(address => Purchase[]) public purchasesOf;

    function numPurchasesOf(address buyer) public constant returns (uint256) {
        return purchasesOf[buyer].length;
    }

    function CoinCrowdICO(address contractAddress, uint256 initialValue, uint256 end) {
        tokenContract = CoinCrowdToken(contractAddress);
        tokenValue = initialValue;
        endTime = end;
    }

    address public updater;  // account in charge of updating the token value

    event UpdateValue(uint256 newValue);

    function updateValue(uint256 newValue) {
        require(msg.sender == updater || msg.sender == owner);
        tokenValue = newValue;
        UpdateValue(newValue);
    }

    function updateUpdater(address newUpdater) onlyOwner {
        updater = newUpdater;
    }

    function updateEndTime(uint256 newEnd) onlyOwner {
        endTime = newEnd;
    }

    modifier beforeEndTime() {
        require(now < endTime);
        _;
    }

    event Buy(address buyer, uint256 value, address indexed ambassador);

    function buy(address buyer, address ambassadorContr) payable beforeEndTime {
        uint256 remaining = tokenContract.balanceOf(this);
        require(remaining > 0);
        address ambassador;
        if (ambassadorContr != address(0)) {
            ambassador = ambassadors[ambassadorContr];
        }
        uint256 oneXCC = 10 ** uint256(decimals);
        uint256 value = msg.value.mul(oneXCC).div(tokenValue);
        if (remaining >= value) {
            tokenContract.transfer(buyer, value);
            if (ambassador != address(0)) {
                communityTokensOf[ambassador] += value;
            }
            purchasesOf[buyer].push(Purchase(value, now, ambassador));
            Buy(buyer, value, ambassador);
        } else {
            tokenContract.transfer(buyer, remaining);
            if (ambassador != address(0)) {
                communityTokensOf[ambassador] += remaining;
            }
            purchasesOf[buyer].push(Purchase(remaining, now, ambassador));
            Buy(buyer, remaining, ambassador);
            uint256 refund = (value - remaining).mul(tokenValue).div(oneXCC);
            buyer.transfer(refund);
        }
    }

    event NewAmbassador(address ambassador, address contr);

    function addAmbassador(address ambassador) onlyOwner {
        Ambassador contr = new Ambassador();
        ambassadors[contr] = ambassador;
        ambassadorContracts.push(contr);
        NewAmbassador(ambassador, contr);
    }

    function withdraw(address to, uint256 value) onlyOwner {
        to.transfer(value);
    }

    function withdrawTokens(address to, uint256 value) onlyOwner returns (bool) {
        return tokenContract.transfer(to, value);
    }

    function () payable {
        buy(msg.sender, 0);
    }
}

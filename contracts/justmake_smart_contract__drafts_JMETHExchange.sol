pragma solidity ^0.4.15;

import './utils/SafeMath.sol';
import './utils/Utils.sol';
import './Owned.sol';

contract JMETHExchange is Owned, Utils {

     using SafeMath for uint256;

     mapping(address => uint256) balances;

}
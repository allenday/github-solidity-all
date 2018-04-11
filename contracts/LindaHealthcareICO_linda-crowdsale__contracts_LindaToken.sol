pragma solidity ^0.4.11;

import './zeppelin/math/SafeMath.sol';
import './zeppelin/token/StandardToken.sol';
import './zeppelin/ownership/Ownable.sol';
import './zeppelin/lifecycle/Pausable.sol';
import './zeppelin/token/MintableToken.sol';


/// @title LindaToken - Crowdfunding code for the Linda Project
/// @author Medwhat
contract LindaToken is MintableToken {

    using SafeMath for uint;
    string public constant name = "LINDA";
    string public constant symbol = "LNDA";
    uint public constant decimals = 18;


}
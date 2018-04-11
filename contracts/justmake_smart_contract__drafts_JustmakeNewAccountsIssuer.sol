pragma solidity ^0.4.15;

import './utils/SafeMath.sol';
import './utils/Utils.sol';
import './Owned.sol';

contract JustmakeNewAccountsIssuer is Owned, Utils {

    using SafeMath for uint256;
    uint256 internal issueAmountJM;
    uint256 internal issueAmountWEI;
    address internal issuer;
    
    mapping(address => uint256) balances;

    function JustmakeNewAccountsIssuer()
        public
    {
        issuer = msg.sender;
        issueAmountJM = 25;
        issueAmountWEI = 200000000000000;
    }
    
    function () payable public {}

    function issue(address _to) 
        public
        validAddress(_to)
        ownerOnly()
        returns (bool)
    {
        /*
        require(
            balances[issuer] >= issueAmountJM
            && issueAmountJM > 0
        );
        
        //Send JM
        balances[issuer] = balances[issuer].sub(issueAmountJM);
        balances[_to] = balances[_to].add(issueAmountJM);
        Transfer(issuer, _to, issueAmountJM);
        */
        
        //Send ETH
        if(_to.send(issueAmountWEI)) {
            return true;
        } else {
            return false;
        }

    }

    function updateIssuer(address _newIssuer) 
        public
        validAddress(_newIssuer)
        ownerOnly()
        returns (bool)
    {
        issuer = _newIssuer;
        return true;
    }

    function updateJMAmount(uint256 _value) 
        public
        ownerOnly()
        returns (bool)
    {
        require(
            _value > 0
        );
        issueAmountJM = _value;
        return true;
    }

    function updateWEIAmount(uint256 _value) 
        public
        ownerOnly()
        returns (bool)
    {
        require(
            _value > 0
        );
        issueAmountWEI = _value;
        return true;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}
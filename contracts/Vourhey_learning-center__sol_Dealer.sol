pragma solidity ^0.4.4;
import 'dao/Core.sol';
import 'token/TokenEmission.sol';

contract Dealer is Owned {
    Core public dao;
    TokenEmission public air;

    /**
     * @dev The Dealer
     */
    function Dealer(address _dao, address _air) {
        dao = Core(_dao);
        air = TokenEmission(_air);
    }

    function setDao(Core _dao) onlyOwner
    { dao = _dao; }

    function setToken(TokenEmission _air) onlyOwner
    { air = _air; }

    function delegateToken(address _address) onlyOwner
    { air.setOwner(_address); }

    /**
     * @dev This function called when lesson assertion passed
     */
    function pay(address _sender, uint _amount) {
        if (!dao.contains(msg.sender)) throw;
        air.emission(_amount);
        air.transfer(_sender, _amount);
    }
}

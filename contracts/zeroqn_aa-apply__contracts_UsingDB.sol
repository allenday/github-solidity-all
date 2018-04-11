pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";


contract UsingDB is Ownable {

    address public db;

    function UsingDB(address _db)
        public
    {
        // constructor
        db = _db;
    }

    function setDB(address _db)
        onlyOwner
        public
    {
        require(_db != 0x0);

        db = _db;
    }

}

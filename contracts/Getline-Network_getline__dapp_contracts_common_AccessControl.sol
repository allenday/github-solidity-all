pragma solidity ^0.4.11;


contract AccessControl {
    mapping(address => bool) public admins;
    mapping(address => bool) public managers;
    
    modifier adminOnly() {
        require(admins[msg.sender] == true);

        _;
    }

    modifier managerOnly() {
        require(managers[msg.sender] == true || admins[msg.sender] == true);

        _;
    }

    function AccessControl() public {
        admins[msg.sender] = true;
    }

    function addAdmin(address newAdmin) public adminOnly {
        if (managers[newAdmin] == true)
            removeManager(newAdmin);
            
        admins[newAdmin] = true;
    }

    function addManager(address newManager) public adminOnly {
        if (admins[newManager] == true)
            removeAdmin(newManager);
        
        managers[newManager] = true;
    }

    function removeAdmin(address oldAdmin) public adminOnly {
        delete admins[oldAdmin];
    }

    function removeManager(address oldManager) public adminOnly {
        delete managers[oldManager];
    }
}

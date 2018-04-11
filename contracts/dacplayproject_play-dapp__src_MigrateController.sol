pragma solidity ^0.4.13;

import "./PLS.sol";

contract MigrateController is DSAuth, TokenController {
    PLS public  pls;

    function MigrateController(address _pls) {
        pls = PLS(_pls);
    }

    /// @notice The owner of this contract can change the controller of the PLS token
    ///  Please, be sure that the owner is a trusted agent or 0x0 address.
    /// @param _newController The address of the new controller
    function changeController(address _newController) public auth {
        require(_newController != 0x0);
        pls.changeController(_newController);
        ControllerChanged(_newController);
    }
    
    // In between the offering and the network. Default settings for allowing token transfers.
    function proxyPayment(address) public payable returns (bool) {
        return false;
    }
    
    function onTransfer(address, address, uint256) public returns (bool) {
        return true;
    }

    function onApprove(address, address, uint256) public returns (bool) {
        return true;
    }

    function mint(address _th, uint256 _amount, bytes data) auth {
        pls.mint(_th, _amount);

        NewIssue(_th, _amount, data);
    }
  
    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns (bool) {
        if (_addr == 0) return false;
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function time() constant returns (uint) {
        return block.timestamp;
    }

    //////////
    // Testing specific methods
    //////////

    /// @notice This function is overridden by the test Mocks.
    function getBlockNumber() internal constant returns (uint256) {
        return block.number;
    }

    //////////
    // Safety Methods
    //////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public auth {
        if (pls.controller() == address(this)) {
            pls.claimTokens(_token);
        }
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }

        ERC20 token = ERC20(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }

    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
    event NewIssue(address indexed _th, uint256 _amount, bytes data);
    event ControllerChanged(address indexed _newController);
}

pragma solidity ^0.4.15;

import "./Roles.sol";
import "./ERC20.sol";
import "./Math.sol";
import "./TokenIceBox.sol";


contract TokenPool is ERC20Events, Math, SecuredWithRoles {
    ERC20 public token;
    mapping(address => bool) public participants;
    address public tokenVault;
    TokenIceBox public iceBox;
    uint participantBonus = 50000000000000000000000;

    function TokenPool(address token_, address tokenVault_, address roles) SecuredWithRoles("TokenPool", roles) {
        token = ERC20(token_);
        tokenVault = tokenVault_;
        iceBox = new TokenIceBox(token_);
    }

    function addParticipant(address participant) roleOrOwner("oracle") {
        if(!participants[participant]) {
            participants[participant] = true;

            uint iceBoxBalance = token.balanceOf(address(iceBox));
            if(iceBoxBalance >= participantBonus){
                iceBox.transfer(tokenVault, participantBonus);
            } else if(iceBoxBalance > 0) {
                iceBox.transfer(tokenVault, iceBoxBalance);
            }
        }
    }

    function removeParticipant(address participant) roleOrOwner("oracle") {
        if(participants[participant]) {
            participants[participant] = false;
        }
    }

    function transfer(address dest, uint wad) roleOrOwner("oracle") {
        require(participants[dest]);
        token.transfer(dest, wad);
    }
}
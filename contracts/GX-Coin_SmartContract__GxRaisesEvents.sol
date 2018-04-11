pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';
import './GxEventsInterface.sol';


contract GxRaisesEvents is GxCallableByDeploymentAdmin {
    GxEventsInterface public events;

    function setEventsContract(address eventsContractAddress) public callableByDeploymentAdmin {
        events = GxEventsInterface(eventsContractAddress);
    }
}
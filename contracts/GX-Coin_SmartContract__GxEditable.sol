pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';
import './GxVersioned.sol';


contract GxEditable is GxCallableByDeploymentAdmin, GxVersioned {
    bool public isEditable = true;

    modifier callableWhenEditable {
        if (isEditable == true) {
            _;
        }
    }

    function setEditable(bool editable) callableByDeploymentAdmin {
        isEditable = editable;
    }
}
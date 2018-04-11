pragma solidity ^0.4.18;

import "./owned.sol";
import "./Application.sol";
import "./ApplicationSource.sol";

/**
 * This contract defines the concept of applications and approvals. An application can be withdrawn by its source.
 *
 * - Application Sources: A set of addresses that can submit applications for approval.
 * - Applicant: The address on whose behalf the application is being made.
 * - Approvers: A set of addresses that can approve applications.
 */
contract SingleApproval is Application, owned {

    event ApproverAdded(address indexed owner, address indexed approver, string description);
    event ApproverRemoved(address indexed owner, address indexed approver);
    event ApplicationSourceAdded(address indexed owner, address indexed source, string description);
    event ApplicationSourceRemoved(address indexed owner, address indexed source);
    event ApplicationSubmitted(address indexed source, address indexed applicant);
    event ApplicationWithdrawn(address indexed source, address indexed applicant);
    event ApplicationRejected(address indexed approver, address indexed source, address indexed applicant, string description);
    event ApplicationApproved(address indexed approver, address indexed source, address indexed applicant, string description);

    mapping(address => bool) public sources;

    mapping(address => bool) public approvers;

    /**
     * Contains all the open applications currently available
     */
    mapping(address => mapping(address => bool)) public applications;

    modifier hasApplicationRights() {
        require(sources[msg.sender] || msg.sender == owner);
        _;
    }

    modifier hasApprovalRights() {
        require(approvers[msg.sender] || msg.sender == owner);
        _;
    }

    function SingleApproval() {
        owner = msg.sender;
    }

    function addApprover(address _approver, string description) byOwner {
        if (approvers[_approver]) {
            return;
        }
        approvers[_approver] = true;
        ApproverAdded(msg.sender, _approver, description);
    }

    function removeApprover(address _approver) byOwner {
        if (!approvers[_approver]) {
            return;
        }
        approvers[_approver] = false;
        ApproverRemoved(msg.sender, _approver);
    }

    function addApplicationSource(ApplicationSource _source, string description) byOwner {
        if (sources[_source]) {
            return;
        }
        sources[_source] = true;
        ApplicationSourceAdded(msg.sender, _source, description);
    }

    function removeApplicationSource(ApplicationSource _source) byOwner {
        if (!sources[_source]) {
            return;
        }
        sources[_source] = false;
        ApproverRemoved(msg.sender, _source);
    }

    function submitApplication(address _applicant) hasApplicationRights {
        var source = msg.sender;
        assert(!applications[source][_applicant]);
        applications[source][_applicant] = true;
        ApplicationSubmitted(source, _applicant);
    }

    function withdrawApplication(address _applicant) hasApplicationRights {
        var source = msg.sender;
        assert(applications[source][_applicant]);
        applications[source][_applicant] = false;
        ApplicationWithdrawn(source, _applicant);
    }

    function hasOpenApplicationFromSource(address source, address _applicant) constant returns (bool) {
        return applications[source][_applicant];
    }

    function hasOpenApplication(address _applicant) constant returns (bool) {
        return hasOpenApplicationFromSource(msg.sender, _applicant);
    }

    function rejectApplication(ApplicationSource _source, address _applicant, string description) hasApprovalRights {
        assert(applications[_source][_applicant]);
        applications[_source][_applicant] = false;
        ApplicationRejected(msg.sender, _source, _applicant, description);
        _source.applicationRejected(_applicant, msg.sender);
    }

    function approveApplication(ApplicationSource _source, address _applicant, string description) hasApprovalRights {
        assert(applications[_source][_applicant]);
        applications[_source][_applicant] = false;
        ApplicationApproved(msg.sender, _source, _applicant, description);
        _source.applicationApproved(_applicant, msg.sender);
    }

}
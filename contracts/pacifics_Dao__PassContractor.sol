import "PassProject.sol";

pragma solidity ^0.4.8;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Project smart contract is used for the management of the Pass Dao projects.
 *
*/

/// @title Contractor smart contract of the Pass Decentralized Autonomous Organisation
contract PassContractor {
    
    // The project smart contract
    PassProject passProject;
    
    // The address of the creator of this smart contract
    address public creator;
    // Address of the recipient;
    address public recipient;

    // End date of the setup procedure
    uint public smartContractStartDate;

    struct proposal {
        // Amount (in wei) of the proposal
        uint amount;
        // A description of the proposal
        string description;
        // The hash of the proposal's document
        bytes32 hashOfTheDocument;
        // A unix timestamp, denoting the date when the proposal was created
        uint dateOfProposal;
        // The amount submitted to a vote
        uint submittedAmount;
        // The sum amount (in wei) ordered for this proposal 
        uint orderAmount;
        // A unix timestamp, denoting the date of the last order for the approved proposal
        uint dateOfLastOrder;
    }
    // Proposals to work for Pass Dao
    proposal[] public proposals;

// Events

    event RecipientUpdated(address indexed By, address LastRecipient, address NewRecipient);
    event Withdrawal(address indexed By, address indexed Recipient, uint Amount);
    event ProposalAdded(address Creator, uint indexed ProposalID, uint Amount, string Description, bytes32 HashOfTheDocument);
    event ProposalSubmitted(address indexed Client, uint Amount);
    event Order(address indexed Client, uint indexed ProposalID, uint Amount);

// Constant functions

    /// @return the actual committee room of the Dao
    function Client() constant returns (address) {
        return passProject.Client();
    }

    /// @return the project smart contract
    function Project() constant returns (PassProject) {
        return passProject;
    }
    
    /// @notice Function used by the client to check the proposal before submitting
    /// @param _sender The creator of the Dao proposal
    /// @param _proposalID The index of the proposal
    /// @param _amount The amount of the proposal
    /// @return true if the proposal can be submitted
    function proposalChecked(
        address _sender,
        uint _proposalID, 
        uint _amount) constant external onlyClient returns (bool) {
        if (_sender != recipient && _sender != creator) return;
        if (_amount <= proposals[_proposalID].amount - proposals[_proposalID].submittedAmount) return true;
    }

    /// @return The number of proposals     
    function numberOfProposals() constant returns (uint) {
        return proposals.length - 1;
    }


// Modifiers

    // Modifier for contractor functions
    modifier onlyContractor {if (msg.sender != recipient) throw; _;}
    
    // Modifier for client functions
    modifier onlyClient {if (msg.sender != Client()) throw; _;}

// Constructor function

    function PassContractor(
        address _creator, 
        PassProject _passProject, 
        address _recipient,
        bool _restore) { 

        if (address(_passProject) == 0) throw;
        
        creator = _creator;
        if (_recipient == 0) _recipient = _creator;
        recipient = _recipient;
        
        passProject = _passProject;
        
        if (!_restore) smartContractStartDate = now;

        proposals.length = 1;
    }

// Setting functions

    /// @notice Function to clone a proposal from the last contractor
    /// @param _amount Amount (in wei) of the proposal
    /// @param _description A description of the proposal
    /// @param _hashOfTheDocument The hash of the proposal's document
    /// @param _dateOfProposal A unix timestamp, denoting the date when the proposal was created
    /// @param _orderAmount The sum amount (in wei) ordered for this proposal 
    /// @param _dateOfOrder A unix timestamp, denoting the date of the last order for the approved proposal
    /// @param _cloneOrder True if the order has to be cloned in the project smart contract
    /// @return Whether the function was successful or not 
    function cloneProposal(
        uint _amount,
        string _description,
        bytes32 _hashOfTheDocument,
        uint _dateOfProposal,
        uint _orderAmount,
        uint _dateOfOrder,
        bool _cloneOrder
    ) returns (bool success) {
            
        if (smartContractStartDate != 0 || recipient == 0
        || msg.sender != creator) throw;
        
        uint _proposalID = proposals.length++;
        proposal c = proposals[_proposalID];

        c.amount = _amount;
        c.description = _description;
        c.hashOfTheDocument = _hashOfTheDocument; 
        c.dateOfProposal = _dateOfProposal;
        c.orderAmount = _orderAmount;
        c.dateOfLastOrder = _dateOfOrder;

        ProposalAdded(msg.sender, _proposalID, _amount, _description, _hashOfTheDocument);
        
        if (_cloneOrder) passProject.cloneOrder(address(this), _proposalID, _orderAmount, _dateOfOrder);
        
        return true;
    }

    /// @notice Function to close the setting procedure and start to use this smart contract
    /// @return True if successful
    function closeSetup() returns (bool) {
        
        if (smartContractStartDate != 0 
            || (msg.sender != creator && msg.sender != Client())) return;

        smartContractStartDate = now;

        return true;
    }
    
// Account Management

    /// @notice Function to update the recipent address
    /// @param _newRecipient The adress of the recipient
    function updateRecipient(address _newRecipient) onlyContractor {

        if (_newRecipient == 0) throw;

        RecipientUpdated(msg.sender, recipient, _newRecipient);
        recipient = _newRecipient;
    } 

    /// @notice Function to receive payments
    function () payable { }
    
    /// @notice Function to allow contractors to withdraw ethers
    /// @param _amount The amount (in wei) to withdraw
    function withdraw(uint _amount) onlyContractor {
        if (!recipient.send(_amount)) throw;
        Withdrawal(msg.sender, recipient, _amount);
    }
    
// Project Manager Functions    

    /// @notice Function to allow the project manager updating the description of the project
    /// @param _projectDescription A description of the project
    /// @param _hashOfTheDocument The hash of the last document
    function updateProjectDescription(string _projectDescription, bytes32 _hashOfTheDocument) onlyContractor {
        passProject.updateDescription(_projectDescription, _hashOfTheDocument);
    }
    
// Management of proposals

    /// @notice Function to make a proposal to work for the client
    /// @param _creator The address of the creator of the proposal
    /// @param _amount The amount (in wei) of the proposal
    /// @param _description String describing the proposal
    /// @param _hashOfTheDocument The hash of the proposal document
    /// @return The index of the contractor proposal
    function newProposal(
        address _creator,
        uint _amount,
        string _description, 
        bytes32 _hashOfTheDocument
    ) external returns (uint) {
        
        if (msg.sender == Client() && _creator != recipient && _creator != creator) throw;
        if (msg.sender != Client() && msg.sender != recipient && msg.sender != creator) throw;

        if (_amount == 0) throw;
        
        uint _proposalID = proposals.length++;
        proposal c = proposals[_proposalID];

        c.amount = _amount;
        c.description = _description;
        c.hashOfTheDocument = _hashOfTheDocument; 
        c.dateOfProposal = now;
        
        ProposalAdded(msg.sender, _proposalID, c.amount, c.description, c.hashOfTheDocument);
        
        return _proposalID;
    }
    
    /// @notice Function used by the client to infor about the submitted amount
    /// @param _sender The address of the sender who submits the proposal
    /// @param _proposalID The index of the contractor proposal
    /// @param _amount The amount (in wei) submitted
    function submitProposal(
        address _sender, 
        uint _proposalID, 
        uint _amount) onlyClient {

        if (_sender != recipient && _sender != creator) throw;    
        proposals[_proposalID].submittedAmount += _amount;
        ProposalSubmitted(msg.sender, _amount);
    }

    /// @notice Function used by the client to order according to the contractor proposal
    /// @param _proposalID The index of the contractor proposal
    /// @param _orderAmount The amount (in wei) of the order
    /// @return Whether the order was made or not
    function order(
        uint _proposalID,
        uint _orderAmount
    ) external onlyClient returns (bool) {
    
        proposal c = proposals[_proposalID];
        
        uint _sum = c.orderAmount + _orderAmount;
        if (_sum > c.amount
            || _sum < c.orderAmount
            || _sum < _orderAmount) return; 

        c.orderAmount = _sum;
        c.dateOfLastOrder = now;
        
        Order(msg.sender, _proposalID, _orderAmount);
        
        return true;
    }
    
}

contract PassContractorCreator {
    
    // Address of the pass Dao smart contract
    PassDao public passDao;
    // Address of the Pass Project creator
    PassProjectCreator public projectCreator;
    
    struct contractor {
        // The address of the creator of the contractor
        address creator;
        // The contractor smart contract
        PassContractor contractor;
        // The address of the recipient for withdrawals
        address recipient;
        // True if meta project
        bool metaProject;
        // The address of the existing project smart contract
        PassProject passProject;
        // The name of the project (if the project smart contract doesn't exist)
        string projectName;
        // A description of the project (can be updated after)
        string projectDescription;
        // The unix creation date of the contractor
        uint creationDate;
    }
    // contractors created to work for Pass Dao
    contractor[] public contractors;
    
    event NewPassContractor(address indexed Creator, address indexed Recipient, PassProject indexed Project, PassContractor Contractor);

    function PassContractorCreator(PassDao _passDao, PassProjectCreator _projectCreator) {
        passDao = _passDao;
        projectCreator = _projectCreator;
        contractors.length = 0;
    }

    /// @return The number of created contractors 
    function numberOfContractors() constant returns (uint) {
        return contractors.length;
    }
    
    /// @notice Function to create a contractor smart contract
    /// @param _creator The address of the creator of the contractor
    /// @param _recipient The address of the recipient for withdrawals
    /// @param _metaProject True if meta project
    /// @param _passProject The address of the existing project smart contract
    /// @param _projectName The name of the project (if the project smart contract doesn't exist)
    /// @param _projectDescription A description of the project (can be updated after)
    /// @param _restore True if orders or proposals are to be cloned from other contracts
    /// @return The address of the created contractor smart contract
    function createContractor(
        address _creator,
        address _recipient, 
        bool _metaProject,
        PassProject _passProject,
        string _projectName, 
        string _projectDescription,
        bool _restore) returns (PassContractor) {
 
        PassProject _project;

        if (_creator == 0) _creator = msg.sender;
        
        if (_metaProject) _project = PassProject(passDao.MetaProject());
        else if (address(_passProject) == 0) 
            _project = projectCreator.createProject(passDao, _projectName, _projectDescription, 0);
        else _project = _passProject;

        PassContractor _contractor = new PassContractor(_creator, _project, _recipient, _restore);
        if (!_metaProject && address(_passProject) == 0 && !_restore) _project.setProjectManager(address(_contractor));
        
        uint _contractorID = contractors.length++;
        contractor c = contractors[_contractorID];
        c.creator = _creator;
        c.contractor = _contractor;
        c.recipient = _recipient;
        c.metaProject = _metaProject;
        c.passProject = _passProject;
        c.projectName = _projectName;
        c.projectDescription = _projectDescription;
        c.creationDate = now;

        NewPassContractor(_creator, _recipient, _project, _contractor);
 
        return _contractor;
    }
    
}

import "PassDao.sol";

pragma solidity ^0.4.8;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Project smart contract is used for the management of the Pass Dao projects.
 *
*/

/// @title Project smart contract of the Pass Decentralized Autonomous Organisation
contract PassProject {

    // The Pass Dao smart contract
    PassDao public passDao;
    
    // The project name
    string public name;
    // The project description
    string public description;
    // The Hash Of the project Document
    bytes32 public hashOfTheDocument;
    // The project manager smart contract
    address projectManager;

    struct order {
        // The address of the contractor smart contract
        address contractorAddress;
        // The index of the contractor proposal
        uint contractorProposalID;
        // The amount of the order
        uint amount;
        // The date of the order
        uint orderDate;
    }
    // The orders of the Dao for this project
    order[] public orders;
    
    // The total amount of orders in wei for this project
    uint public totalAmountOfOrders;

    struct resolution {
        // The name of the resolution
        string name;
        // A description of the resolution
        string description;
        // The date of the resolution
        uint creationDate;
    }
    // Resolutions of the Dao for this project
    resolution[] public resolutions;
    
// Events

    event OrderAdded(address indexed Client, address indexed ContractorAddress, uint indexed ContractorProposalID, uint Amount, uint OrderDate);
    event ProjectDescriptionUpdated(address indexed By, string NewDescription, bytes32 NewHashOfTheDocument);
    event ResolutionAdded(address indexed Client, uint indexed ResolutionID, string Name, string Description);

// Constant functions  

    /// @return the actual committee room of the Dao   
    function Client() constant returns (address) {
        return passDao.ActualCommitteeRoom();
    }
    
    /// @return The number of orders 
    function numberOfOrders() constant returns (uint) {
        return orders.length - 1;
    }
    
    /// @return The project Manager address
    function ProjectManager() constant returns (address) {
        return projectManager;
    }

    /// @return The number of resolutions 
    function numberOfResolutions() constant returns (uint) {
        return resolutions.length - 1;
    }
    
// modifiers

    // Modifier for project manager functions 
    modifier onlyProjectManager {if (msg.sender != projectManager) throw; _;}

    // Modifier for the Dao functions 
    modifier onlyClient {if (msg.sender != Client()) throw; _;}

// Constructor function

    function PassProject(
        PassDao _passDao, 
        string _name,
        string _description,
        bytes32 _hashOfTheDocument) {

        passDao = _passDao;
        name = _name;
        description = _description;
        hashOfTheDocument = _hashOfTheDocument;
        
        orders.length = 1;
        resolutions.length = 1;
    }
    
// Internal functions

    /// @dev Internal function to register a new order
    /// @param _contractorAddress The address of the contractor smart contract
    /// @param _contractorProposalID The index of the contractor proposal
    /// @param _amount The amount in wei of the order
    /// @param _orderDate The date of the order 
    function addOrder(

        address _contractorAddress, 
        uint _contractorProposalID, 
        uint _amount, 
        uint _orderDate) internal {

        uint _orderID = orders.length++;
        order d = orders[_orderID];
        d.contractorAddress = _contractorAddress;
        d.contractorProposalID = _contractorProposalID;
        d.amount = _amount;
        d.orderDate = _orderDate;
        
        totalAmountOfOrders += _amount;
        
        OrderAdded(msg.sender, _contractorAddress, _contractorProposalID, _amount, _orderDate);
    }
    
// Setting functions

    /// @notice Function to allow cloning orders in case of upgrade
    /// @param _contractorAddress The address of the contractor smart contract
    /// @param _contractorProposalID The index of the contractor proposal
    /// @param _orderAmount The amount in wei of the order
    /// @param _lastOrderDate The unix date of the last order 
    function cloneOrder(
        address _contractorAddress, 
        uint _contractorProposalID, 
        uint _orderAmount, 
        uint _lastOrderDate) {
        
        if (projectManager != 0) throw;
        
        addOrder(_contractorAddress, _contractorProposalID, _orderAmount, _lastOrderDate);
    }
    
    /// @notice Function to set the project manager
    /// @param _projectManager The address of the project manager smart contract
    /// @return True if successful
    function setProjectManager(address _projectManager) returns (bool) {

        if (_projectManager == 0 || projectManager != 0) return;
        
        projectManager = _projectManager;
        
        return true;
    }

// Project manager functions

    /// @notice Function to allow the project manager updating the description of the project
    /// @param _projectDescription A description of the project
    /// @param _hashOfTheDocument The hash of the last document
    function updateDescription(string _projectDescription, bytes32 _hashOfTheDocument) onlyProjectManager {
        description = _projectDescription;
        hashOfTheDocument = _hashOfTheDocument;
        ProjectDescriptionUpdated(msg.sender, _projectDescription, _hashOfTheDocument);
    }

// Client functions

    /// @dev Function to allow the Dao to register a new order
    /// @param _contractorAddress The address of the contractor smart contract
    /// @param _contractorProposalID The index of the contractor proposal
    /// @param _amount The amount in wei of the order
    function newOrder(
        address _contractorAddress, 
        uint _contractorProposalID, 
        uint _amount) onlyClient {
            
        addOrder(_contractorAddress, _contractorProposalID, _amount, now);
    }
    
    /// @dev Function to allow the Dao to register a new resolution
    /// @param _name The name of the resolution
    /// @param _description The description of the resolution
    function newResolution(
        string _name, 
        string _description) onlyClient {

        uint _resolutionID = resolutions.length++;
        resolution d = resolutions[_resolutionID];
        
        d.name = _name;
        d.description = _description;
        d.creationDate = now;

        ResolutionAdded(msg.sender, _resolutionID, d.name, d.description);
    }
}

contract PassProjectCreator {
    
    event NewPassProject(PassDao indexed Dao, PassProject indexed Project, string Name, string Description, bytes32 HashOfTheDocument);

    /// @notice Function to create a new Pass project
    /// @param _passDao The Pass Dao smart contract
    /// @param _name The project name
    /// @param _description The project description (not mandatory, can be updated after by the creator)
    /// @param _hashOfTheDocument The Hash Of the project Document (not mandatory, can be updated after by the creator)
    function createProject(
        PassDao _passDao,
        string _name, 
        string _description, 
        bytes32 _hashOfTheDocument
        ) returns (PassProject) {

        PassProject _passProject = new PassProject(_passDao, _name, _description, _hashOfTheDocument);

        NewPassProject(_passDao, _passProject, _name, _description, _hashOfTheDocument);

        return _passProject;
    }
}
    

pragma solidity 0.4.10;

contract DCReum {
  event LogWorkflowCreation(uint256 indexed workflowId, bytes32 indexed workflowName, address indexed creator);
  event LogExecution(uint256 indexed workflowId, uint256 indexed activityId, address indexed executor);

  struct Workflow {
    bytes32 name;

    //activity data:
    bytes32[] activityNames;
    uint256 included;
    uint256 executed;
    uint256 pending;

    //relations
    uint256[] includesTo;
    uint256[] excludesTo;
    uint256[] responsesTo;
    uint256[] conditionsFrom;
    uint256[] milestonesFrom;

    //auth:
    uint256 authDisabled;
    address[] authAccounts;
    uint256[] authWhitelist;
  }

  Workflow[] workflows;

  function getWorkflowCount() public constant returns (uint256) {
    return workflows.length;
  }

  function getWorkflowName(uint256 workflowId) public constant returns (bytes32) {
    return workflows[workflowId].name;
  }

  function getActivityCount(uint256 workflowId) public constant returns (uint256) {
    return workflows[workflowId].activityNames.length;
  }

  function getActivityName(uint256 workflowId, uint256 activityId) public constant returns (bytes32) {
     return workflows[workflowId].activityNames[activityId];
  }

  function isIncluded(uint256 workflowId, uint256 activityId) public constant returns (bool) {
    return ((workflows[workflowId].included & (1<<activityId)) != 0);
  }

  function isExecuted(uint256 workflowId, uint256 activityId) public constant returns (bool) {
    return ((workflows[workflowId].executed & (1<<activityId)) != 0);
  }

  function isPending(uint256 workflowId, uint256 activityId) public constant returns (bool) {
    return ((workflows[workflowId].pending & (1<<activityId)) != 0);
  }
  
  function getRelations(uint256 relations) private constant returns (uint8[]) {
    uint i;
    uint count = 0;
    for (i = 0; i < 256; i++) {
      if ((relations & (1<<i)) != 0)
        count++;
    }

    uint j = 0;
    var result = new uint8[](count);
    for (i = 0; i < 256; i++) {
      if ((relations & (1<<i)) != 0)
        result[j++] = uint8(i);
    }

    return result;
  }

  function getIncludes(uint256 workflowId, uint256 activityId) external constant returns (uint8[]) {
    return getRelations(workflows[workflowId].includesTo[activityId]);
  }

  function getExcludes(uint256 workflowId, uint256 activityId) external constant returns (uint8[]) {
    return getRelations(workflows[workflowId].excludesTo[activityId]);
  }

  function getResponses(uint256 workflowId, uint256 activityId) external constant returns (uint8[]) {
    return getRelations(workflows[workflowId].responsesTo[activityId]);
  }

  function getConditions(uint256 workflowId, uint256 activityId) external constant returns (uint8[]) {
    return getRelations(workflows[workflowId].conditionsFrom[activityId]);
  }

  function getMilestones(uint256 workflowId, uint256 activityId) external constant returns (uint8[]) {
    return getRelations(workflows[workflowId].milestonesFrom[activityId]);
  }

  function getAccountWhitelist(uint256 workflowId, uint256 activityId) public constant returns (address[]) {
    var workflow = workflows[workflowId];
    uint i;
    uint j;
    uint count;

    for (i = 0; i < workflow.authWhitelist.length; i++)
      if ((workflow.authWhitelist[i] & (1<<activityId)) != 0)
        count++;

    j = 0;
    var result = new address[](count);
    for (i = 0; i < workflow.authWhitelist.length; i++)
      if ((workflow.authWhitelist[i] & (1<<activityId)) != 0)
        result[j++] = workflow.authAccounts[i];

    return result;
  }

  function isAuthDisabled(uint256 workflowId, uint256 activityId) public constant returns (bool) {
    return ((workflows[workflowId].authDisabled & (1<<activityId)) == 0);
  }

  function canExecute(uint256 workflowId, uint256 activityId) public constant returns (bool) {
    var workflow = workflows[workflowId];
    uint32 i;

    // sender address must have rights to execute or authorization must be disabled entirely
    if ((workflow.authDisabled & (1<<activityId)) == 0) {
      for (i = 0; i < workflow.authAccounts.length; i++)
        if (workflow.authAccounts[i] == msg.sender && (workflow.authWhitelist[i] & (1<<activityId)) != 0)
          break; // sender authorized

      // sender not in authAccounts array or was not authorized by authWhitelist
      if (i == workflow.authAccounts.length)
        return false;
    }
    
    // activity must be included
    if ((workflow.included & (1<<activityId)) == 0) return false;

    // all conditions executed
    if(workflow.conditionsFrom[activityId] & (~workflow.executed & workflow.included) != 0) return false;

    // no milestones pending
    if(workflow.milestonesFrom[activityId] & (workflow.pending & workflow.included) != 0) return false;

    return true;
  }

  function execute(uint256 workflowId, uint256 activityId) {
    var workflow = workflows[workflowId];
    uint32 i;

    if (!canExecute(workflowId, activityId)) throw;

    // executed activity
    workflow.executed = workflow.executed | (1<<activityId);
    workflow.pending = workflow.pending & ~(1<<activityId);

    // exclude and include relations pass
    // note includes happens after the exclude pass    
    workflow.included = (workflow.included & ~workflow.excludesTo[activityId]) | workflow.includesTo[activityId];

    // response relations pass
    workflow.pending = (workflow.pending | workflow.responsesTo[activityId]);

    LogExecution(workflowId, activityId, msg.sender);
  }

  function createWorkflow(
    bytes32 workflowName,
    bytes32[] activityNames,

    // packed state variables
    uint256 includedStates,
    uint256 executedStates,
    uint256 pendingStates,

    // relations
    uint256[] includesTo,
    uint256[] excludesTo,
    uint256[] responsesTo,
    uint256[] conditionsFrom,
    uint256[] milestonesFrom,

    // auth
    uint256 authDisabled,
    address[] authAccounts,
    uint256[] authWhitelist
  ) {
    assert(activityNames.length <= 256);
    assert(activityNames.length == includesTo.length);
    assert(activityNames.length == excludesTo.length);
    assert(activityNames.length == responsesTo.length);
    assert(activityNames.length == conditionsFrom.length);
    assert(activityNames.length == milestonesFrom.length);
    assert(authAccounts.length == authWhitelist.length);

    var workflow = workflows[workflows.length++];
    workflow.name = workflowName;

    // activity data
    workflow.activityNames = activityNames;
    workflow.included = includedStates;
    workflow.executed = executedStates;
    workflow.pending = pendingStates;

    // relations
    workflow.includesTo = includesTo;
    workflow.excludesTo = excludesTo;
    workflow.responsesTo = responsesTo;
    workflow.conditionsFrom = conditionsFrom;
    workflow.milestonesFrom = milestonesFrom;

    // auth
    workflow.authDisabled = authDisabled;
    workflow.authAccounts = authAccounts;
    workflow.authWhitelist = authWhitelist;
    
    LogWorkflowCreation(workflows.length - 1, workflow.name, msg.sender);
  }
}

pragma solidity 0.4.10;

contract DCReum {
  event LogWorkflowCreation(uint256 indexed workflowId, bytes32 indexed workflowName, address indexed creator);
  event LogExecution(uint256 indexed workflowId, uint256 indexed activityId, address indexed executor);

  enum RelationType {
    Include, Exclude, Response, Condition, Milestone
  }

  struct Workflow {
    bytes32 name;
    
    // note that while activities is indexed with 256 bit,
    // it must not surpass 2^32 entries
    Activity[] activities;
  }

  struct Activity {
    bytes32 name;

    // activity state
    bool included;
    bool executed;
    bool pending;

    // activity relations
    uint32[] includeTo;
    uint32[] excludeTo;
    uint32[] responseTo;
    uint32[] conditionFrom;
    uint32[] milestoneFrom;

    // individual accounts with rights to execute
    address[] authAccounts;

    // if true anyone can execute
    bool authDisabled;
  }

  Workflow[] workflows;

  // Not intended for use in transactions, as returned structs will exist in memory instead of as storage pointers!
  function getWorkflowActivity(uint256 workflowId, uint256 activityId) private constant returns (Workflow, Activity) {
    var workflow = workflows[workflowId];
    var activity = workflow.activities[activityId];
    return (workflow, activity);
  }

  function getWorkflowName(uint256 workflowId) public constant returns (bytes32) {
    return workflows[workflowId].name;
  }

  function getActivityCount(uint256 workflowId) public constant returns (uint256) {
    return workflows[workflowId].activities.length;
  }

  function getActivityName(uint256 workflowId, uint256 activityId) public constant returns (bytes32) {
    var (workflow, activity) = getWorkflowActivity(workflowId, activityId);
    return activity.name;
  }

  function isIncluded(uint256 workflowId, uint256 activityId) public constant returns (bool) {
    var (workflow, activity) = getWorkflowActivity(workflowId, activityId);
    return activity.included;
  }

  function isExecuted(uint256 workflowId, uint256 activityId) public constant returns (bool) {
    var (workflow, activity) = getWorkflowActivity(workflowId, activityId);
    return activity.executed;
  }

  function isPending(uint256 workflowId, uint256 activityId) public constant returns (bool) {
    var (workflow, activity) = getWorkflowActivity(workflowId, activityId);
    return activity.pending;
  }

  function getIncludes(uint256 workflowId, uint256 activityId) external constant returns (uint32[]) {
    var (workflow, activity) = getWorkflowActivity(workflowId, activityId);
    return activity.includeTo;
  }

  function getExcludes(uint256 workflowId, uint256 activityId) external constant returns (uint32[]) {
    var (workflow, activity) = getWorkflowActivity(workflowId, activityId);
    return activity.excludeTo;
  }

  function getResponses(uint256 workflowId, uint256 activityId) external constant returns (uint32[]) {
    var (workflow, activity) = getWorkflowActivity(workflowId, activityId);
    return activity.responseTo;
  }

  function getConditions(uint256 workflowId, uint256 activityId) external constant returns (uint32[]) {
    var (workflow, activity) = getWorkflowActivity(workflowId, activityId);
    return activity.conditionFrom;
  }

  function getMilestones(uint256 workflowId, uint256 activityId) external constant returns (uint32[]) {
    var (workflow, activity) = getWorkflowActivity(workflowId, activityId);
    return activity.milestoneFrom;
  }

  function getAccountWhitelist(uint256 workflowId, uint256 activityId) public constant returns (address[]) {
    var (workflow, activity) = getWorkflowActivity(workflowId, activityId);
    return activity.authAccounts;
  }

  function isAuthDisabled(uint256 workflowId, uint256 activityId) public constant returns (bool) {
    var (workflow, activity) = getWorkflowActivity(workflowId, activityId);
    return activity.authDisabled;
  }

  function canExecute(uint256 workflowId, uint256 activityId) public constant returns (bool) {
    var workflow = workflows[workflowId];
    var activity = workflow.activities[activityId];
    uint32 i;
    uint32 fromId;

    // sender address must have rights to execute or authentication must be disabled entirely
    if (!activity.authDisabled) {
      for (i = 0; i < activity.authAccounts.length; i++) {
        if (activity.authAccounts[i] == msg.sender)
          break;
      }

      // sender not in authAccounts array
      if (i == activity.authAccounts.length)
        return false;
    }

    // activity must be included
    if (!activity.included) return false;

    // all conditions executed
    for (i = 0; i < activity.conditionFrom.length; i++) {
      fromId = activity.conditionFrom[i];
      if (!workflow.activities[fromId].executed) return false;
    }

    // no milestones pending
    for (i = 0; i < activity.milestoneFrom.length; i++) {
      fromId = activity.milestoneFrom[i];
      if (workflow.activities[fromId].pending) return false;
    }

    return true;
  }

  function execute(uint256 workflowId, uint256 activityId) {
    var workflow = workflows[workflowId];
    var activity = workflow.activities[activityId];
    uint32 i;
    uint32 toId; 

    if (!canExecute(workflowId, activityId)) throw;

    // executed activity
    activity.executed = true;
    activity.pending = false;

    // exclude relations pass
    for (i = 0; i < activity.excludeTo.length; i++) {
      toId = activity.excludeTo[i];
      workflow.activities[toId].included = false;
    }

    // include relations pass
    // note this happens after the exlude pass
    for (i = 0; i < activity.includeTo.length; i++) {
      toId = activity.includeTo[i];
      workflow.activities[toId].included = true;
    }

    // response relations pass
    for (i = 0; i < activity.responseTo.length; i++) {
      toId = activity.responseTo[i];
      workflow.activities[toId].pending = true;
    }

    LogExecution(workflowId, activityId, msg.sender);
  }

  function createWorkflow(
    // ugly squash hack to decrease stack depth
    // 0: workflow name
    // 1-end: activity names
    bytes32[] names,
    bool[3][] activityStates, // included, executed, pending

    // ugly squash hack to decrease stack depth
    // length is amount of activities
    // 0: counts for relationTypes and relationActivityIds
    // 1: counts for authAccounts
    uint32[2][] activityData,
    RelationType[] relationTypes,
    uint32[] relationActivityIds,

    address[] authAccounts,
    bool[] authDisabled
  ) {
    var workflow = workflows[workflows.length++];
    uint256 i;
    uint256 j;
    uint32 relationIndex = 0;
    uint32 authAccountIndex = 0;

    assert(activityData.length == names.length - 1);
    assert(activityData.length == authDisabled.length);

    workflow.name = names[0];

    // activities
    for (i = 0; i < activityData.length; i++) {
      var activity = workflow.activities[workflow.activities.length++];
      activity.name = names[1 + i];
      activity.included = activityStates[i][0];
      activity.executed = activityStates[i][1];
      activity.pending = activityStates[i][2];
      activity.authDisabled = authDisabled[i];

      // relations
      for (j = 0; j < activityData[i][0]; j++) {
        if (relationTypes[relationIndex] == RelationType.Include)
          activity.includeTo.push(relationActivityIds[relationIndex]);
        else if (relationTypes[relationIndex] == RelationType.Exclude)
          activity.excludeTo.push(relationActivityIds[relationIndex]);
        else if (relationTypes[relationIndex] == RelationType.Response)
          activity.responseTo.push(relationActivityIds[relationIndex]);
        else if (relationTypes[relationIndex] == RelationType.Condition)
          activity.conditionFrom.push(relationActivityIds[relationIndex]);
        else if (relationTypes[relationIndex] == RelationType.Milestone)
          activity.milestoneFrom.push(relationActivityIds[relationIndex]);
        
        relationIndex++;
      }

      // individual account auth
      for (j = 0; j < activityData[i][1]; j++) {
        activity.authAccounts.push(authAccounts[authAccountIndex++]);
      }
    }
    
    LogWorkflowCreation(workflows.length - 1, workflow.name, msg.sender);
  }
}

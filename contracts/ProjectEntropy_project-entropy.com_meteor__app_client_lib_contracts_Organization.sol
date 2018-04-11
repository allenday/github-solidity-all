
contract Organization {

  // Action types
  struct Action {

    uint256 previous;     // Previous in the array
    uint256 parent;       // Parent Action (optional)

    string name;          // The name of the Action
    string summary;       // Markdown enabled description
    address from;         // Who created it
    uint created;         // Timestamp of when it was created

    uint kind;            // The Action type
                          //    0 : normal
                          //          Action will be carried out by steering commitee.
                          //          Any wie will be unlocked for this purpose.
                          //    1 : blocked
                          //          blocks parent until this new action is resolved.
                          //    2 : objection
                          //          disables the parent Action if successful
                          //          re-accepts the parent Action if successful
                          //    3 : nomination
                          //          send_to added to steering comittee


    uint state;           // The state of the Action
                          //    0 : voting
                          //          Voting is in progress and conditions have not yet been met
                          //          for the Action to move on.
                          //    1 : accepted
                          //          The Action is currently accepted
                          //    2 : rejected
                          //          The Action is currently rejected
                          //    3 : blocked
                          //          until a child Action is resolved, this Action is blocked
                          //    4 : done
                          //          This has been completed

    string tags;

    // main data
    bytes32 data;

    // ethereum handling
    uint amount;      // (optional) How much ether is available
    address send_to;  // (optional) The address ether should be sent if successful

    // votes
    uint yes_votes;  // Total yes votes
    uint no_votes;   // Total no votes
    uint vote_count;   // Total votes
    mapping (address => bool) votedYes;
    mapping (address => bool) votedNo;

  }

  // first entry of the linked list of actions
  uint256 public head;

  // total ether from all approved actions
  uint public needed_ether;

  Action[] actions;

  // Action change events, including voting
  event NewAction(uint256 action_key);
  event NewVote(uint256 action_key);


  function getAction(uint256 key) returns (bytes32 action)
  {
    Action a = actions[key];
    /*return a;*/
  }


  /**
   * Vote for an action at key
   * @param key The key of the Action
   * @return Whether the vote was successful
   */
  function vote(uint256 key) onlyTokenholders returns (bool success)
  {
    Action a = actions[key];
    a.vote_count += 1;
    NewVote(key);
    return true;
  }

  function addAction(uint256 key, string _name, string _summary, uint _kind, bytes32 _data, uint _amount) returns (bool){
    Action a = actions[key];

    // Safety check incase it's not empty
    if(a.data != ""){
      return false;
    }

    a.name = _name;
    a.summary = _summary;
    a.data = _data;
    // a.kind = _kind;

    a.amount = _amount;

    a.from = msg.sender;
    a.created = now;

    // Link
    a.previous = head;

    // Set this element as the new head.
    head = key;

    // Update global record of amount of funds needed
    needed_ether += a.amount;


    NewAction(key);
    return true;
  }

  // Only people who hold at least one token can do these actions
  modifier onlyTokenholders {
    /*if (balanceOf(msg.sender) == 0) throw;*/
    // Todo: Finish this
    _
  }
}

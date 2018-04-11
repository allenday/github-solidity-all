pragma solidity ^0.4.0;
contract Betfunding {

    struct Bets{
        uint numSuccessGamblers;
        uint successBounty;
        mapping(uint => address) orderSuccessGamblers;

        uint numFailGamblers;
        uint failBounty;
        mapping(uint => address) orderFailGamblers;

        mapping(address => uint) amount;
        uint distributionIndex;
    }

    struct Project{
        address creator;
        uint deadline; // timestamp
        address oracle;
        bool verified;
        Bets bets;

        string name; // to IPFS
        string desc; // to IPFS
        // TODO: Add IPFS hash
    }

    // List of projects
    uint public numProjects;
    mapping(uint => Project) projects;

    // To claim the profits
    mapping(address => uint) public balances;

    // Events
    event NewProject(uint indexed projectId, address creator);
    event Bet(uint indexed projectId, address indexed gambler, uint amount, bool success);
    event Result(uint indexed projectId, address indexed oracle, bool result);
    event Distribution(uint indexed projectId);

    modifier isFirstBet(uint projectId) {
        if (projects[projectId].bets.amount[msg.sender] > 0 )
            throw;
        _;
    }

    modifier sendsEther() {
        if (msg.value == 0 )
            throw;
        _;
    }

    modifier projectInRange(uint projectId) {
        if (projectId >= numProjects)
            throw;
        _;
    }

    modifier onlyOracle(uint projectId) {
        if (projects[projectId].oracle != msg.sender)
            throw;
        _;
    }

    modifier bettingTime(uint projectId) {
        if (now > projects[projectId].deadline)
            throw;
        _;
    }

    modifier verificationTime(uint projectId) {
        if (now < projects[projectId].deadline || now > projects[projectId].deadline + 7 days)
            throw;
        _;
    }

    modifier closed(uint projectId) {
        if (now < projects[projectId].deadline + 7 days)
            throw;
        _;
    }

    /*
     * Functions
     */

    // TODO: Change attributes name and description for IPFS hash
    function createProject(string name, string desc, uint deadline, address oracle){
        Project newProject = projects[numProjects];

        newProject.creator = msg.sender;
        newProject.deadline = deadline;
        newProject.oracle = oracle;

        // TODO: Change to IPFS hash
        newProject.name = name;
        newProject.desc = desc;

        NewProject(numProjects, msg.sender);
        numProjects++;
    }

    function bet(uint projectId, bool success)
        payable
        isFirstBet(projectId)
        projectInRange(projectId)
        sendsEther
        bettingTime(projectId)
    {
        Bets bets = projects[projectId].bets;

        if(success){
            bets.orderSuccessGamblers[bets.numSuccessGamblers] = msg.sender;
            bets.successBounty += msg.value;
            bets.numSuccessGamblers++;
        }else{
            bets.orderFailGamblers[bets.numFailGamblers] = msg.sender;
            bets.failBounty += msg.value;
            bets.numFailGamblers++;
        }

        bets.amount[msg.sender] += msg.value;

        Bet(projectId, msg.sender, msg.value, success);
    }

    function verify(uint projectId, bool success)
        projectInRange(projectId)
        verificationTime(projectId)
        onlyOracle(projectId)
    {
        projects[projectId].verified = success;
    }

    function updateBalances(uint projectId)
        projectInRange(projectId)
        closed(projectId)
    {
        Project project = projects[projectId];
        uint txLimit;
        address user;
        uint amountBet;
        uint bounty = project.bets.successBounty + project.bets.failBounty;

        if(project.verified){
            // To avoid tx gas limit
            txLimit = project.bets.distributionIndex + 100;
            if(txLimit > project.bets.numSuccessGamblers){
                txLimit = project.bets.numSuccessGamblers;

                Distribution(projectId); // last iteration
            }

            // Distribution
            while(project.bets.distributionIndex < txLimit){
                user = project.bets.orderSuccessGamblers[project.bets.distributionIndex];
                amountBet = project.bets.amount[user];

                // The user receives his share of the bounty
                // Sumatory (used to weight by order):
                uint sum = (project.bets.numSuccessGamblers * (project.bets.numSuccessGamblers + 1)) / 2;
                //  Percent of bounty received by the user weighed by order of bets:
                uint shareOrder = 10000*(project.bets.numSuccessGamblers-project.bets.distributionIndex)/sum;
                // Percent of the bounty received by the user weighed by amount bet:
                uint shareAmount = 10000*amountBet/project.bets.successBounty;
                // Mean of the previous percents:
                uint share = ((shareOrder+shareAmount)/2);
                // Finally, the user gets back his bet + his share of the failBounty:
                balances[user] += amountBet + (share*project.bets.failBounty)/10000;

                project.bets.distributionIndex++;
            }
        }else{
            // To avoid tx gas limit
            txLimit = project.bets.distributionIndex + 100;
            if(txLimit > project.bets.numFailGamblers){
                txLimit = project.bets.numFailGamblers;

                Distribution(projectId); // last iteration
            }

            // Distribution
            while(project.bets.distributionIndex < txLimit){
                user = project.bets.orderFailGamblers[project.bets.distributionIndex];
                amountBet = project.bets.amount[user];

                // The user receives his share of the bounty
                balances[user] += ((amountBet*bounty*10000)/project.bets.failBounty)/10000;

                project.bets.distributionIndex++;
            }
        }
    }

    function claimProfits(){
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        if(!msg.sender.send(amount))
            throw;
    }

    /*
     * Getters
     */

    function getProject(uint i) constant projectInRange(i)
        returns(
            address creator,
            uint deadline,
            address oracle,
            bool verified,
            string name,
            string desc
        )
    {
        creator = projects[i].creator;
        deadline = projects[i].deadline;
        oracle = projects[i].oracle;
        verified = projects[i].verified;

        // TODO: Change attributes name and description for IPFS hash
        name = projects[i].name;
        desc = projects[i].desc;
    }

    function getBets(uint i) constant projectInRange(i)
        returns(
            uint numSuccessGamblers,
            uint successBounty,
            uint numFailGamblers,
            uint failBounty
        )
    {
        numSuccessGamblers = projects[i].bets.numSuccessGamblers;
        successBounty = projects[i].bets.successBounty;

        numFailGamblers = projects[i].bets.numFailGamblers;
        failBounty = projects[i].bets.failBounty;
    }
}

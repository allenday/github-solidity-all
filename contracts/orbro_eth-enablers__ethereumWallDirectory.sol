contract WallDirectory {

    struct EthereumWallDefinition {
        address contractAddress;
        string name;
        bool enabled;
        address owner;
        uint created;
    }

    address public owner;
    uint public fees;

    EthereumWallDefinition[] public walls;
    mapping ( bytes32 =&gt; uint256 ) public index;

    // Only the owner of the site can do certain things
    modifier admin { if (msg.sender == owner) _ }

    // User display name storage:
    mapping ( address =&gt; string ) public userDisplayNames;

    event newWall(string id);
    event newUserDisplayName(address account);

    // Wall directory service
    function WallDirectory() {
        fees = 50 ether;
        owner = msg.sender;
        walls.length = 1;
        walls[0].enabled = false;
    }


    // Add an entry from the directory:
    function insert(address contractAddress, string name) {
        if(bytes(name).length &lt; 2) throw;
        bool isOwner = msg.sender == owner;

        if(!isOwner &amp;&amp; msg.value != fees) throw;

        uint256 i = index[sha3(name)];
        if(i == 0){
            i = walls.length;
            walls.length++;
            walls[i].created = block.timestamp;
        }
        else if(!isOwner &amp;&amp; walls[i].owner != msg.sender &amp;&amp; walls[i].owner != 0) throw;

        if(walls[i].owner == 0) {
            walls[i].created = block.timestamp;
        }

        walls[i].contractAddress = contractAddress;
        walls[i].name = name;
        walls[i].enabled = true;
        walls[i].owner = msg.sender;
        index[sha3(name)] = i;

        newWall(name);
    }

    // Remove an entry from the directory:
    function remove(string name) {
        if(bytes(name).length &lt; 2) throw;

        uint256 i = index[sha3(name)];
        if(i == 0) throw;
        if(msg.sender != owner &amp;&amp; walls[i].owner != msg.sender) throw;

        walls[i].name = "";
        walls[i].enabled = false;
        walls[i].contractAddress = 0;
        walls[i].owner = 0;
        walls[i].created = 0;
    }

    // Sets a user's nickname:
    function setUserDisplayName(string name) {
        // Restrict username length to 32 characters
        if(bytes(name).length &gt; 32) throw;

        // Set it!
        userDisplayNames[msg.sender] = name;

        // Dispatch our event
        newUserDisplayName(msg.sender);
    }

    // Lets the owner withdraw any fees
    function collectFees(uint amount, address recipient) admin {
        if(!recipient.send(amount)) throw;
    }

    // Lets the owner set registration fees
    function setFees(uint amount) admin {
        fees = amount;
    }

    // Allows the current owner to transfer it to someone new
    function transferOwnership(address newOwner) admin {
        owner = newOwner;
    }

}
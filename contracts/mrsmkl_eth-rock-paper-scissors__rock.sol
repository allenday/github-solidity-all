
contract RockPaperScissors {

    struct Pending {
        address player;
        address other;
        uint8 reply;
        uint32 time;
    }

    event Resolved(uint256 id, address p1, address p2, uint8 result,  uint8 v1,  uint8 v2);

    address owner;
    
    mapping (uint256 => address) commits;
    mapping (uint256 => Pending) pending;
    
    function RockPaperScissors() {
        owner = msg.sender;
    }
    
    function collect() {
        owner.send(1 ether);
    }

    uint256[] log;
    uint32 log_length;
    
    uint64 constant BET = 1;
    // uint64 constant BET = 1 ether;

    function cleanLog() returns (uint256[]) {
        uint32 j = 0;
        for (uint32 i = 0; i < log.length; i++) {
          if (poll(i) != 0) {
            log[j++] = log[i];
          }
        }
        log_length = j;
        return log;
    }

    uint256[] res;
    function getLog() returns (uint256[]) {
        res.length = log.length*2;
        for (uint32 i = 0; i < log.length; i++) {
          res[i*2] = log[i];
          res[i*2+1] = poll(i);
        }
        return res;
    }

    function poll(uint32 i) returns (uint256) {
        uint256 e = log[i];
        if (commits[e] != 0) return 1;
        if (pending[e].player != 0) return 2;
        return 0;
    }

    function start(uint256 commit) {
        if (msg.value >= BET && commits[commit] == 0 && pending[commit].player == 0) {
            commits[commit] = msg.sender;
            log.length++;
            // if (log.length < log_length) log.length = log_length*2;
            log[log.length-1] = commit;
        }
    }

    function cancel(uint256 commit) {
        if (commits[commit] == msg.sender) {
            delete commits[commit];
            msg.sender.send(BET);
        }
    }

    function reply(uint256 commit, uint8 rep) {
        if (commits[commit] != 0 && pending[commit].player == 0 && msg.value >= BET && rep < 3) {
           pending[commit] = Pending(commits[commit], msg.sender, rep, uint32(block.number));
           delete commits[commit];
        }
    }

    function timeout(uint256 commit) {
        Pending p = pending[commit];
        if (p.player == 0 || p.time + 20 > block.number) return;
        p.other.send(BET);
        Resolved(commit, p.player, p.other, 2, 3, p.reply);
        delete pending[commit];
    }

    function show(uint256 commit, uint256 value) {
        Pending p = pending[commit];
        if (p.player != 0 && uint256(sha3(value)) == commit) {
           uint8 k = uint8((value % 256) % 3);
           if (k == p.reply) {
               p.player.send(BET);
               p.other.send(BET);
               Resolved(commit, p.player, p.other, 0, k, p.reply);
           }
           else if (k == 0 && p.reply == 2 || k == 1 && p.reply == 0 || k == 2 && p.reply == 1) {
               p.player.send(2*BET);
               Resolved(commit, p.player, p.other, 1, k, p.reply);
           }
           else {
               p.other.send(2*BET);
               Resolved(commit, p.player, p.other, 2, k, p.reply);
           }
           delete pending[commit];
        }
    }

}

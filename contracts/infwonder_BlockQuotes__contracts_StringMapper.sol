pragma solidity ^0.4.6;

import "./strings.sol";

contract StringMapper {
    using strings for *;

    bool locked;
    uint public itemcount;

    struct ipfsdata {
      uint postid;
      string title;
      string qmhash;
      uint datemark;
      address poster;
      uint mediacount;
      mapping(uint => string) ipfsmedia; 
    }

    mapping(uint => string) listum; // for looping list
    mapping(uint => bytes32) listhash; // for looping list
    mapping(bytes32 => ipfsdata) map;
    mapping(uint => bytes32) deleted;
    mapping(address => uint) members;

    struct associate {
        uint replycount;
        mapping(uint => string) posts;
        mapping(uint => uint) rdmap;
        mapping(uint => address) rpmap;
    }

    mapping(bytes32 => associate) replies;

    modifier NoReentrancy() {
        if (locked) throw;
        locked = true;
        _;
        locked = false;
    }

    modifier minimalFee() {
        if (msg.value < 3 ether) throw;
        _;
    }

    modifier isMember() {
        if (members[msg.sender] == 0) throw;
        _;
    }

    modifier isAuthor(bytes32 hash) {
        if (map[hash].poster == 0 || map[hash].poster != msg.sender) throw;
        _;
    }

    function StringMapper() payable { 
        itemcount = 0;
    }

    function stringToBytes32(string memory source) constant returns (bytes32 result) {
        assembly {
           result := mload(add(source, 32))
        }
    }

    function stringToBytes32s(string memory source, uint N) constant returns (bytes32 result) {
        assembly {
           result := mload(add(source, N))
        }
    }

    function title(string memory source) constant returns (bytes32[7] result) {
        uint srclen = bytes(source).length;
        uint parts;

        if (srclen <= 32) { 
          parts = 1;
        } else {
          uint restpt = srclen % 32;
          parts = (srclen - restpt) / 32;
          if (restpt != 0) parts++;
        }

        if (parts > 4) parts = 4;

        for (uint i = 1; i <= parts; i++) {
          uint N = i * 32;
          result[i-1] = stringToBytes32s(source, N);
        }
    }

    function becomeMember() payable minimalFee NoReentrancy returns(bool) {
        members[msg.sender] = members[msg.sender] + msg.value;
        return true;
    }

    function checkMembership(address thisone) constant returns(bool status, uint balance) {
        if (members[thisone] == 0) {
          status = false;
          balance = 0;
        } else {
          status = true;
          balance = members[thisone];
        }
    }

    function addKeyValue(string title, string mainhash, string mediahashs, uint mediacount) payable NoReentrancy isMember returns(bool) {
        if (bytes(title).length == 0 || bytes(mainhash).length == 0 || mediacount < 1) throw;

        bytes32 hash = sha3(title);
        if(bytes(map[hash].title).length != 0) throw;
        itemcount++;

        map[hash] = ipfsdata(itemcount, title, mainhash, now, msg.sender, mediacount);

        if (mediacount > 1) {
          var delim  = ','.toSlice();
          var media  = mediahashs.toSlice();
          var mcount = media.count(delim)+1;

          // split mediahashs into ipfsmedia mapping
          for(uint i = 1; i <= mcount; i++) {
            map[hash].ipfsmedia[i] = media.split(delim).toString();
          }
        }

        // update data
        listum[itemcount] = title;
        listhash[itemcount] = hash;
        replies[hash] = associate(0);

        return true;
    }

    function addReply(bytes32 postid, string comment, uint tip, address recipient) payable NoReentrancy isMember returns(bool) {
        if (bytes(comment).length == 0 || bytes(map[postid].title).length == 0 || members[msg.sender] <= tip) throw;
        replies[postid].replycount++;
        uint rid = replies[postid].replycount;
        replies[postid].posts[rid] = comment;
        replies[postid].rdmap[rid] = now;
        replies[postid].rpmap[rid] = msg.sender;

        members[msg.sender] = members[msg.sender] - tip;

        if (!recipient.send(tip)) {
          members[msg.sender] = members[msg.sender] + tip;
          throw;
        }

        return true;
    }

    function getReplyRaw(bytes32 postid, uint id) constant returns(string resp, uint date, address poster) {
        if (replies[postid].replycount < id) throw;
        resp = replies[postid].posts[id];
        date = replies[postid].rdmap[id];
        poster = replies[postid].rpmap[id];
    }

    function getReplyCount(bytes32 postid) constant returns (uint count) {
        return replies[postid].replycount;
    }

    function getReply(bytes32 postid, uint start, uint end) constant returns(bytes32[7][] results) {
        if (start < 0 || end < 0 || replies[postid].replycount == 0) throw;

        if (end+1 > replies[postid].replycount) end = replies[postid].replycount - 1;

        uint al = end - start + 1;

        if (al > 32 || al <= 0) throw; // 32 items per page max

        results = new bytes32[7][](al);
        for (uint i = start; i <= end; i++) {
          results[i-start] = title(replies[postid].posts[i+1]);
          results[i-start][4] = bytes32(replies[postid].rdmap[i+1]);
          results[i-start][5] = bytes32(replies[postid].rpmap[i+1]);
        }

        return results;
    }

    function dumpData(uint start, uint end) constant returns(bytes32[7][] results) { 
        if (start < 0 || end < 0 || itemcount == 0) throw;

        if (end+1 > itemcount) end = itemcount - 1;

        uint al = end - start + 1;

        if (al > 32 || al <= 0) throw; // 32 items per page max

        results = new bytes32[7][](al);

        for (uint i = start; i <= end; i++) {
            results[i-start] = title(listum[i+1]);
            bytes32 hash = listhash[i+1];
            results[i-start][4] = hash;
            results[i-start][5] = bytes32(map[hash].datemark);
            results[i-start][6] = bytes32(map[hash].poster);
        }

        return results; 
    }

    function getIdByHash(bytes32 hash) constant returns(uint id, address author) {
        author = map[hash].poster;
        id = map[hash].postid;
        if(bytes(listum[id]).length == 0 || listhash[id] != hash) throw;
    }

    function getValueByHash(bytes32 hash) constant returns(uint date, string value, address author, string title, uint mcount, bytes32[2][] mediahashs){
        date = map[hash].datemark;
        author = map[hash].poster;
        value = map[hash].qmhash;
        title = listum[map[hash].postid];
        mcount = map[hash].mediacount;
        uint i;

        mediahashs = new bytes32[2][](mcount-1);

        for (i = 1; i <=mcount-1; i++) { 
            mediahashs[i-1][0] = stringToBytes32s(map[hash].ipfsmedia[i], 32);
            mediahashs[i-1][1] = stringToBytes32s(map[hash].ipfsmedia[i], 64);
        }
    }

    function delKeyValue(uint id, bytes32 hash) payable isAuthor(hash) returns(bool) {
        if(bytes(listum[id]).length == 0 || listhash[id] != hash) throw;
        deleted[id] = hash;

        if (packTable(id) == false) throw;
    }

    function packTable(uint id) payable returns(bool) {
        uint newtotal;
        if (id == 1) {
          newtotal = 0;
        } else {
          newtotal = id - 1;
        } 

        uint delete_count = 0;
      
        for (uint i = id; i <= itemcount; i++) {
            if (uint(deleted[i]) != 0) {
                delete map[deleted[i]];
                delete replies[deleted[i]];
                delete_count++;
                delete listum[i];
                delete listhash[i];
                delete deleted[i];
                continue; 
            }

            listum[i - delete_count] = listum[i];
            listhash[i - delete_count] = listhash[i];
            map[ listhash[i] ].postid = i - delete_count;

            if (delete_count != 0) {
                delete listum[i];
                delete listhash[i];
            }
            newtotal++;
        }

        itemcount = newtotal;
        return true;
    }

    function () payable {}
}

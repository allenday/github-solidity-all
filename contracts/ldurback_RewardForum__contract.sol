contract RewardForum {
    struct Post {
        uint title;
        uint text;
        address poster;
        
        int votes;
        uint overwriteNum;
        mapping (address => uint) hasVotedOnOverwrite;
        
        uint timestamp;
    }
    
    address owner;
    uint constant TOTAL_POSTS = 1000;
    Post[1000] posts; // compiler errors if constant is used
                      // make sure that these match
    uint nextPost;
    
    uint constant TOTAL_TOP_POSTS = 10;
    uint[10] topPosts; // compiler errors if constant is used
                       // make sure that these match
    
    uint initTime;
    
    // breaks up subscription time into chunks so that
    // vote worth scales better over time
    uint constant VOTE_WORTH_SCALE = 256;
    
    uint subscriptionFee;
    
    // timestamps are in seconds, so 1 week = 604800
    uint constant SUBSCRIPTION_TIME_OUT = 900;
    mapping (address => uint) subscriptionLastPaid;
    
    uint constant FRAC_TO_TOP_NUM = 4;
    uint constant FRAC_TO_TOP_DEN = 5;
    
    function RewardForum(uint _initialSubscriptionFee) {
        owner = msg.sender;
        initTime = now;
        subscriptionFee = _initialSubscriptionFee;
        
        // initially put owner's address in 0th post so that he gets
        // all subscription fees before initial post is made
        posts[0].poster = owner;
    }
    
    function transferOwnership(address newOwner) {
        if (msg.sender != owner)
            return;
            
        owner = newOwner;
    }
    
    function changeSubscriptionFee(uint _newSubscriptionFee) {
        if (msg.sender != owner)
            return;
        
        subscriptionFee = _newSubscriptionFee;
    }
    
    function paySubscriptionFee() returns (bool success) {
        // don't let people overpay
        if (now <= subscriptionLastPaid[msg.sender] + SUBSCRIPTION_TIME_OUT) {
            msg.sender.send(msg.value);
            
            return false;
        }
        
        // owner gets a free subscription
        if (msg.sender == owner || msg.value >= subscriptionFee) {
            // mark subscription as paid now
            subscriptionLastPaid[msg.sender] = now;
            
            // pay out to top posts
            for(uint loop = 0; loop < TOTAL_TOP_POSTS; loop++) {
                posts[topPosts[loop]].poster.send(
                    (msg.value * FRAC_TO_TOP_NUM / FRAC_TO_TOP_DEN)
                    / TOTAL_TOP_POSTS);
            }
            
            // pay out to owner
            owner.send(this.balance);
            
            return true;
        }
        else {
            // if subscription fee is not met, return to sender
            msg.sender.send(msg.value);
            
            return false;
        }
    }
    
    function deletePost(uint _postNum) {
        if (msg.sender != owner) return;
        
        delete posts[nextPost].title;
        delete posts[nextPost].text;
        delete posts[nextPost].poster;
        delete posts[nextPost].timestamp;
        delete posts[nextPost].votes;
    }
    
    function createPost(uint _title, uint _text) {
        // only allow subscribers to create posts
        if (now > subscriptionLastPaid[msg.sender] + SUBSCRIPTION_TIME_OUT) {
            return;
        }
        
        posts[nextPost].title = _title;
        posts[nextPost].text = _text;
        posts[nextPost].poster = msg.sender;
        posts[nextPost].overwriteNum++;
        posts[nextPost].timestamp = now;
        delete posts[nextPost].votes;
        
        nextPost++;
    }
    
    function voteWorth() constant returns (int worth) {
        return int((VOTE_WORTH_SCALE * (now - initTime))/SUBSCRIPTION_TIME_OUT + 1);
    }
    
    function vote(uint _postNum, bool upVote) returns (int votes) {
        // only allow subscribers to vote if they haven't yet voted on the post
        if ((now <= subscriptionLastPaid[msg.sender] + SUBSCRIPTION_TIME_OUT) &&
            (posts[_postNum].hasVotedOnOverwrite[msg.sender]
                < posts[_postNum].overwriteNum)
            ) {
        
            if (upVote)
            {
                posts[_postNum].votes += voteWorth();
            }
            else
            {
                posts[_postNum].votes -= voteWorth();
            }
            
            votes = posts[_postNum].votes;
            
            // check if post is among the top posts
            bool amongTopPosts = false;
            for (uint loop = 0; loop < TOTAL_TOP_POSTS; loop++) {
                if (topPosts[loop] == _postNum) {
                    amongTopPosts = true;
                    break;
                }
            }
            
            // if post belongs among the top posts and isn't already
            // place it at the bottom
            if (!amongTopPosts
            && votes >= posts[topPosts[TOTAL_TOP_POSTS-1]].votes) {
                amongTopPosts = true;
                topPosts[TOTAL_TOP_POSTS-1] = _postNum;
            }
            
            // resort top posts if now among top posts or belongs among
            if (amongTopPosts) sortTopPosts();
            
            // set user as having voted
            posts[_postNum].hasVotedOnOverwrite[msg.sender] =
                posts[_postNum].overwriteNum;
        }
    }
    
    function sortTopPosts() private {
        // bubble sort
        
        bool swapped = true;
        for (int n = int(TOTAL_TOP_POSTS - 1); swapped && n > 0; n--) {
            swapped = false;
            for (uint va=0; va < uint(n); va++) {
                if (posts[topPosts[va]].votes > posts[topPosts[va+1]].votes) {
                    uint swap = topPosts[va];
                    topPosts[va] = topPosts[va+1];
                    topPosts[va+1] = swap;
                    swapped = true;
                }
            }
        }
    }
    
    function getTitle(uint _postNum) constant returns (uint) {
        return posts[_postNum].title;
    }
    
    function getText(uint _postNum) constant returns (uint) {
        return posts[_postNum].text;
    }
	
	function getPoster(uint _postNum) constant returns (address) {
		return posts[_postNum].poster;
	}
    
    function getVotes(uint _postNum) constant returns (int) {
        return posts[_postNum].votes;
    }
    
    function hasVoted(uint _postNum) constant returns (bool) {
        return (posts[_postNum].overwriteNum
            == posts[_postNum].hasVotedOnOverwrite[msg.sender]);
    }
    
    function getTimestamp(uint _postNum) constant returns (uint) {
        return posts[_postNum].timestamp;
    }
    
    function getSubscriptionFee() constant returns (uint) {
        return subscriptionFee;
    }
    
    function getSubscriptionLastPaid() constant 
        returns (uint) {
        return subscriptionLastPaid[msg.sender];
    }
}

contract Forum {
    
    mapping( uint => Forum ) public forums; // forum id points to Forum
    mapping( uint => bytes32[] ) public forums_topics; // forum id points to array of Topic IDs
    
    mapping( bytes32 => Topic ) public topics;  // topic id points to Topic
    mapping( bytes32 => bytes32[] ) public topic_posts; // topic id points to array of Post IDs
    
    mapping( bytes32 => Post ) public posts; // post id points to Post
    
    uint public ForumCount;
    
    struct Forum {
        address owner;
        string name;
        uint TopicCount;
    }
    struct Topic {
        address owner;
        string name;
        string content;
        uint PostCount;
    }
    struct Post {
        address owner;
        string name;
        string content;
    }
    
    function createForum( string name ) returns( uint forumId ) {
        forumId = ForumCount++;
        Forum f = forums[ forumId ];
        f.name = name;
        f.owner = msg.sender;
    }
    
    function createTopic( string name, string content, uint forum ) returns( bytes32 topicId ) {
        topicId = sha3( name, content );
        var topic = Topic( msg.sender, name, content, 0 );
        topics[ topicId ] = topic;
        
        forums_topics[ forum ].push( topicId );
        
        Forum f = forums[ forum ];
        f.TopicCount++;
    }
    
    function createPost( string name, string content, bytes32 topic ) returns( bytes32 postId ) {
        postId = sha3( name, content );
        var post = Post( msg.sender, name, content );
        posts[ postId ] = post;
        
        topic_posts[ topic ].push( postId );
        
        Topic t = topics[ topic ];
        t.PostCount++;
    }
    
    
}

contract Post {

    address private owner;
    address private author;
    address private index;
    address private board;
    bytes32 private title;
    bytes32 private image;
    Comments private comments;
    mapping (uint => bytes32) private content;
    uint private block;
    uint private number;
    aArray private up;
    aArray private down;

    struct aArray {
        uint size;
        mapping (uint => address) array;
    }

    struct Comments {
        uint size;
        mapping (uint => Comment) array;
    }

    struct Comment {
        address user;
        uint block;
        bytes32 t1;
        bytes32 t2;
        bytes32 t3;
    }

    function Post(address _owner, address _author, address _board, bytes32 _title, bytes32 _image, bytes32 c1, bytes32 c2, bytes32 c3, bytes32 c4, bytes32 c5, bytes32 c6, bytes32 c7, bytes32 c8) {
        owner = address(_owner);
        author = address(_author);
        index = address(msg.sender);
        board = address(_board);
        title = _title;
        image = _image;
        content[0] = c1;
        content[1] = c2;
        content[2] = c3;
        content[3] = c4;
        content[4] = c5;
        content[5] = c6;
        content[6] = c7;
        content[7] = c8;
        comments = Comments(0);
        up = aArray(0);
        down = aArray(0);
    }

    function setIds(uint _number, uint _block){
        number = _number;
        block = _block;
    }

    function getData() constant returns (address, address, bytes32, bytes32, uint, uint, uint, uint, uint) {
        return (owner, board, title, image, comments.size, up.size, down.size, block, number);
    }

    function getContent() constant returns (bytes32, bytes32, bytes32, bytes32, bytes32, bytes32, bytes32, bytes32) {
        return (content[0], content[1], content[2], content[3], content[4], content[5], content[6], content[7]);
    }

    function getBoard() constant returns (address) {
        return board;
    }

    function getComment(uint index) constant returns (address, uint, bytes32, bytes32, bytes32) {
        if (index < comments.size)
            return (comments.array[index].user, comments.array[index].block, comments.array[index].t1, comments.array[index].t2, comments.array[index].t3);
        return( 0x0, 0, "", "", "");
    }

    function destroy() {
        if (index != address(msg.sender))
            suicide(owner);
    }

    function addComment(address _user, uint _block, bytes32 _t1, bytes32 _t2, bytes32 _t3) constant returns (bool) {
        if (index != address(msg.sender))
            return false;
        comments.array[comments.size] = Comment({
            user : _user,
            block : _block,
            t1 : _t1,
            t2 : _t2,
            t3 : _t3
        });
        comments.size ++;
        return true;
    }

    function giveUp(address user_address) constant returns (bool){
        if (index != address(msg.sender))
                return false;
        for(uint i = 0; i < down.size; i ++)
            if (down.array[i] == user_address)
                return false;
        for(i = 0; i < up.size; i ++)
            if (up.array[i] == user_address){
                if (i == (up.size-1)){
                    delete up.array[i];
                } else {
                    for(uint z = i; z < up.size; z ++)
                        up.array[z] = up.array[z+1];
                    delete up.array[up.size-1];
                }
                up.size --;
                return true;
            }
        up.array[up.size] = user_address;
        up.size ++;
        return true;
    }

    function giveDown(address user_address) constant returns (bool){
        if (index != address(msg.sender))
                return false;
        for(uint i = 0; i < up.size; i ++)
            if (up.array[i] == user_address)
                return false;
        for(i = 0; i < down.size; i ++)
            if (down.array[i] == user_address){
                if (i == (down.size-1)){
                    delete down.array[i];
                } else {
                    for(uint z = i; z < down.size; z ++)
                        down.array[z] = down.array[z+1];
                    delete down.array[down.size-1];
                }
                down.size --;
                return true;
            }
        down.array[down.size] = user_address;
        down.size ++;
        return true;
    }

    function getOwner() constant returns (address) {
        return address(owner);
    }

}

contract Board {

    address private owner;
    address private index;
    bytes32 private name;
    aArray private posts;
    aArray private users;

    struct aArray {
        uint size;
        mapping (uint => address) array;
    }

    function Board(address _owner, bytes32 _name) {
        name = _name;
        index = msg.sender;
        owner = _owner;
        posts = aArray(0);
        users = aArray(0);
    }

    function destroy() {
        if (index != address(msg.sender))
            suicide(owner);
    }

    function getName() constant returns (bytes32) {
        return name;
    }

    function getInfo() constant returns (address, bytes32, uint, uint) {
        return (owner, name, posts.size, users.size);
    }

    function getOwner() constant returns (address) {
        return address(owner);
    }

    function getPost(uint i) constant returns (address) {
        if (i < posts.size)
            return (posts.array[i]);
        return 0x0;
    }

    function getUser(uint i) constant returns (address) {
        if (index != address(msg.sender))
            return 0x0;
        if (i < users.size)
            return (users.array[i]);
        return 0x0;
    }

    function addPostOnBoard(address _user, address post_address) constant returns (bool)  {
        if (index == address(msg.sender))
            for( uint i = 0; i < users.size; i ++)
                if (users.array[i] == address(_user)){
                    posts.array[posts.size] = address(post_address);
                    posts.size ++;
                    return true;
                }
        return false;
    }

    function removePost(address post_address) constant returns (bool) {
        if (index != address(msg.sender))
            return false;
        for( uint i = 0; i < posts.size; i ++)
            if (posts.array[i] == post_address) {
                if (i == (posts.size-1)){
                    delete posts.array[i];
                } else {
                    for( uint z = i + 1; z < posts.size; z ++)
                        posts.array[z-1] = posts.array[z];
                    delete posts.array[posts.size-1];
                }
                posts.size --;
                return true;
            }
        return false;
    }

    function addUser(address new_user_address) constant returns (bool) {
        if (index != address(msg.sender))
            return false;
        users.array[users.size] = new_user_address;
        users.size ++;
        return true;
    }

    function removeUser(address user_address) constant returns (bool) {
        if (index != address(msg.sender))
            return false;
        for( uint i = 0; i < users.size; i ++)
            if (users.array[i] == user_address) {
                if (i == (users.size-1))
                    delete users.array[i];
                else {
                    for( uint z = i + 1; z < users.size; z ++)
                        users.array[z-1] = users.array[z];
                    delete users.array[users.size-1];
                }
                users.size --;
                return true;
            }
        return false;
    }

}

contract User {

    address private owner;
    address private index;
    bytes32 private email;
    bytes32 private username;
    bytes32 private name;
    bytes32 private imageurl;
    bytes10 private birth;
    bytes32 private location;
    bytes32 private url1;
    bytes32 private url2;
    aArray private boards;
    aArray private posts;

    struct aArray {
        uint size;
        mapping (uint => address) array;
    }

    function User(address _owner, bytes32 _username) {
        owner = address(_owner);
        index = address(msg.sender);
        username = _username;
        boards = aArray(0);
        posts = aArray(0);
    }

    function edit(address _owner, bytes32 _name, bytes32 _email, bytes32 _imageurl, bytes10 _birth, bytes32 _location, bytes32 _url1, bytes32 _url2) constant returns ( bool ) {
        if ((owner != _owner) || (index != address(msg.sender)))
            return false;
        name = _name;
        email = _email;
        imageurl = _imageurl;
        birth = _birth;
        location = _location;
        url1 = _url1;
        url2 = _url2;
        return true;
    }

    function addBoard(address board_address) constant returns ( bool ) {
        if (index != address(msg.sender))
            return false;
        for(uint i = 0; i < boards.size; i ++)
            if (boards.array[i] == board_address)
                return false;
        boards.array[boards.size] = board_address;
        boards.size ++;
        return true;
    }

    function getBoard(uint i) constant returns (address) {
        if (i < boards.size)
            return (boards.array[i]);
        return 0x0;
    }

    function getPost(uint i) constant returns (address) {
        if (i < posts.size)
            return (posts.array[i]);
        return 0x0;
    }

    function removeBoard(address board_address) constant returns ( bool ) {
        if (index != address(msg.sender))
            return false;
        for( uint i = 0; i < boards.size; i ++)
            if (boards.array[i] == board_address) {
                if (i == (boards.size-1)){
                    delete boards.array[i];
                } else {
                    for( uint z = i; z < boards.size; z ++)
                        boards.array[z] = boards.array[z+1];
                    delete boards.array[boards.size-1];
                }
                boards.size --;
                return true;
            }
        return false;
    }

    function addPostOnUser(address post_address) constant returns (bool) {
        if (index == address(msg.sender)){
            posts.array[posts.size] = address(post_address);
            posts.size ++;
            return true;
        }
        return false;
    }

    function removePost(address post_address) constant returns (bool) {
        if (index != address(msg.sender))
            return false;
        for( uint i = 0; i < posts.size; i ++)
            if (posts.array[i] == post_address) {
                if (i == (posts.size-1)){
                    Post(posts.array[i]).destroy();
                    delete posts.array[i];
                } else {
                    for( uint z = i; z < posts.size; z ++)
                        posts.array[z] = posts.array[z+1];
                    Post(posts.array[posts.size-1]).destroy();
                    delete posts.array[posts.size-1];
                }
                posts.size --;
                return true;
            }
        return false;
    }

    function destroy () {
        if (index != address(msg.sender))
            suicide(owner);
    }

    function getUsername() constant returns (bytes32) {
        return username;
    }

    function getData() constant returns (address, bytes32, bytes32, uint, uint) {
        return (address(this), username, name, uint(boards.size), uint(posts.size));
    }

    function getProfile() constant returns (address, bytes32, bytes32, bytes32, bytes32, bytes10, bytes32, bytes32, bytes32) {
        return (address(this), username, name, email, location, birth, imageurl, url1, url2);
    }

    function getOwner() constant returns (address) {
        return owner;
    }

}

contract OpenContentIndex {

    bytes32 constant version = "0.1.1";

    aArray private boards;
    aArray private users;
    aArray private posts;

    struct aArray {
        uint size;
        mapping (uint => address) array;
    }

    event log (bytes32 message);
    event logAddress (address message);
    event logInt (uint message);

    function OpenContentIndex() {
        users = aArray(0);
        boards = aArray(0);
        posts = aArray(0);
    }

    function getIndexInfo()constant returns (bytes32, uint, uint, uint) {
        return (version, users.size, boards.size, posts.size);
    }

/*--------------------------------------------- TAGS ---------------------------------------------*/

    function createBoard( bytes32 new_board_name ) constant returns (bool) {
        for( uint i = 0; i < boards.size; i ++)
            if (Board(boards.array[i]).getName() == bytes32(new_board_name))
                return false;
        for(uint z = 0; z < users.size; z ++)
            if (User(users.array[z]).getOwner() == address(tx.origin)){
                Board newBoard = new Board(address(tx.origin), new_board_name);
                newBoard.addUser(User(users.array[z]));
                boards.array[boards.size] = address(newBoard);
                boards.size ++;
                User(users.array[z]).addBoard(address(newBoard));
                return true;
            }
        return false;
    }

    function removeBoard(address board_address) constant returns ( bool ) {
        if (address(tx.origin) != Board(board_address).getOwner())
            return false;
        for( uint i = 0; i < boards.size; i ++)
            if (boards.array[i] == board_address){
                if (i == (boards.size-1)){
                    Board(boards.array[i]).destroy();
                    delete boards.array[i];
                } else {
                    for( uint z = i; z < boards.size; z ++)
                        boards.array[z] = boards.array[z+1];
                    Board(boards.array[boards.size-1]).destroy();
                    delete boards.array[boards.size-1];
                }
                for(i = 0; i < users.size; i ++)
                    if (User(users.array[i]).getOwner() == address(tx.origin)){
                        Board(board_address).removeUser(User(users.array[i]));
                        User(users.array[i]).removeBoard(board_address);
                        boards.size --;
                        return true;
                    }
            }
        return false;
    }

    function getBoardInfo(address board_address) constant returns (address, bytes32, uint, uint) {
        for( uint i = 0; i < boards.size; i ++)
            if ( address(boards.array[i]) == board_address )
                return Board(boards.array[i]).getInfo();
        return (0x0, "", 0, 0);
    }

/*--------------------------------------------- USERS ---------------------------------------------*/

    function createUser(bytes32 _username) constant returns (bool){
        for( uint i = 0; i < users.size; i ++)
            if ((User(users.array[i]).getUsername() == _username) || (User(users.array[i]).getOwner() == address(tx.origin)))
                return false;
        users.array[users.size] = new User(address(tx.origin), _username);
        users.size ++;
        return true;
    }

    function editUser(bytes32 _name, bytes32 _email, bytes32 _imageurl, bytes10 _birth, bytes32 _location, bytes32 _url1, bytes32 _url2) returns (bool) {
        for( uint i = 0; i < users.size; i ++)
            if (User(users.array[i]).getOwner() == address(tx.origin)) {
                User(users.array[i]).edit(address(tx.origin), _name, _email, _imageurl, _birth, _location, _url1, _url2);
                return true;
            }
        return false;
    }

    function addBoardOnUser(address board_address) returns (bool) {
        for( uint i = 0; i < users.size; i ++)
            if (User(users.array[i]).getOwner() == address(tx.origin)){
                Board(board_address).addUser(User(users.array[i]));
                User(users.array[i]).addBoard(board_address);
                return true;
            }
        return false;
    }

    function removeBoardOnUser(address board_address) returns (bool) {
        for( uint i = 0; i < users.size; i ++)
            if (User(users.array[i]).getOwner() == address(tx.origin)){
                Board(board_address).removeUser(User(users.array[i]));
                User(users.array[i]).removeBoard(board_address);
                return true;
            }
        return false;
    }

    function removeUser() constant returns (bool) {
        for( uint i = 0; i < users.size; i ++)
            if (User(users.array[i]).getOwner() == address(tx.origin)){
                if (i == (users.size-1)){
                    User(users.array[i]).destroy();
                    delete users.array[i];
                } else {
                    for( uint z = i; z < users.size; z ++)
                        users.array[z] = users.array[z+1];
                    User(users.array[users.size-1]).destroy();
                    delete users.array[users.size-1];
                }
                users.size --;
                return true;
            }
        return false;
    }

    function getUserByUsername(bytes32 _username) constant returns (address) {
        for( uint i = 0; i < users.size; i ++)
            if (User(users.array[i]).getUsername() == _username)
                return User(users.array[i]);
        return (0x0);
    }

    function getUserByAddress(address _owner) constant returns (address) {
        for( uint i = 0; i < users.size; i ++)
            if ( User(users.array[i]).getOwner() == _owner )
                return User(users.array[i]);
        return (0x0);
    }

/*--------------------------------------------- POSTS ---------------------------------------------*/

    function getHomePost(uint i) constant returns (address) {
        if (i < posts.size)
            return posts.array[i];
        return (0x0);
    }

    function addComment(address post_address, bytes32 t1, bytes32 t2, bytes32 t3) constant returns (bool) {
        for( uint z = 0; z < users.size; z ++)
            if (User(users.array[z]).getOwner() == address(tx.origin))
                for( uint i = 0; i < posts.size; i ++)
                    if (posts.array[i] == post_address){
                        Post(posts.array[i]).addComment(address(tx.origin), block.number, t1, t2, t3);
                        return true;
                    }
        return false;
    }

    function giveUp(address post_address) constant returns (bool) {
        for( uint z = 0; z < users.size; z ++)
            if (User(users.array[z]).getOwner() == address(tx.origin))
                for( uint i = 0; i < posts.size; i ++)
                    if (posts.array[i] == post_address){
                        Post(posts.array[i]).giveUp(address(tx.origin));
                        return true;
                    }
        return false;
    }

    function giveDown(address post_address) constant returns (bool) {
        for( uint z = 0; z < users.size; z ++)
            if (User(users.array[z]).getOwner() == address(tx.origin))
                for( uint i = 0; i < posts.size; i ++)
                    if (posts.array[i] == post_address){
                        Post(posts.array[i]).giveDown(address(tx.origin));
                        return true;
                    }
        return false;
    }

    function createPost(address _user, address _board, bytes32 _title, bytes32 _image, bytes32 c1, bytes32 c2, bytes32 c3, bytes32 c4, bytes32 c5, bytes32 c6, bytes32 c7, bytes32 c8) returns (bool) {
        if (User(address(_user)).getOwner() == address(tx.origin)){
            Post newPost = new Post(address(tx.origin), address(_user), _board, _title, _image, c1, c2, c3, c4, c5, c6, c7, c8);
            Board(address(_board)).addPostOnBoard(address(_user), address(newPost));
            Post(address(newPost)).setIds(posts.size, block.number);
            User(address(_user)).addPostOnUser(address(newPost));
            posts.array[posts.size] = address(newPost);
            posts.size ++;
            return true;
        }
        return false;
    }

    function removePost(address post_address) returns (bool) {
        for( uint i = 0; i < posts.size; i ++)
            if ((posts.array[i] == post_address) && (Post(posts.array[i]).getOwner() == address(tx.origin)) )
                for( uint z = 0; z < users.size; z ++)
                    if (User(users.array[z]).getOwner() == address(tx.origin)){
                        Board(Post(posts.array[i]).getBoard()).removePost(post_address);
                        User(users.array[z]).removePost(post_address);
                        if (i == (posts.size-1)){
                            delete posts.array[i];
                        } else {
                            for(z = i; z < posts.size; z ++)
                                posts.array[z] = posts.array[z+1];
                            delete posts.array[posts.size-1];
                        }
                        posts.size --;
                        return true;
                    }
        return false;
    }

}

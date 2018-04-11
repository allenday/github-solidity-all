import 'Logging.sol';

contract Hookrz is Logging {
    /////////////////////////////////////////
	// FIELDS
    /////////////////////////////////////////

    // map of requests (requestId => Request)
    mapping (int => Request) private requests;
    // map of bids
    mapping (int => Bid) private bids;


	/////////////////////////////////////////
    // TYPES
    /////////////////////////////////////////

    // enumeration for request status
    enum RequestStatus { Uninitialized, Requested, Fulfilled, Withdrawn }

    // enumeration for bid status
    enum BidStatus { Uninitialized, Offered, Accepted, Withdrawn }

    // defines request
    struct Request {
        int id;
        RequestStatus status;
        int userId;
    }

    // defines bid
    struct Bid {
        int id;
        BidStatus status;
        int restaurantId;
        int requestId;
    }

    /////////////////////////////////////////
	// EVENTS
    /////////////////////////////////////////

    // fired when a request is registered
	event RequestAdded(int indexed userId, int indexed requestId);
    // fired when a request is fulfilled
    event RequestFulfilled(int indexed userId, int indexed requestId, int indexed bidId);
    // fired when a request is withdrawn
    event RequestWithdrawn(int indexed userId, int indexed requestId);
    // fired when a bid for a request is registered
	event BidAdded(int indexed restaurantId, int indexed bidId, int indexed requestId);
    // fired when a bid for a request is accepted
    event BidAccepted(int indexed restaurantId, int indexed bidId, int indexed requestId);
    //fired when a bid for a request is withdrawn
    event BidWithdrawn(int indexed restaurantId, int indexed bidId, int indexed requestId);


    /////////////////////////////////////////
    // MODIFIERS
    /////////////////////////////////////////

    // only allowing non-existing requests
    modifier onlyNewRequest(int requestId)
    {
        if(requests[requestId].status != RequestStatus.Uninitialized) {
            throw;
        }
        _
    }

    // only allowing active requests
    modifier onlyActiveRequest(int requestId)
    {
        if(requests[requestId].status != RequestStatus.Requested) {
            throw;
        }
        _
    }

    // only allowing non-existing bids
    modifier onlyNewBid(int bidId)
    {
        if(bids[bidId].status != BidStatus.Uninitialized) {
            throw;
        }
        _
    }

    // only allowing active bids
    modifier onlyActiveBid(int bidId)
    {
        if(bids[bidId].status != BidStatus.Offered) {
            throw;
        }
        _
    }


    /////////////////////////////////////////
	// METHODS
    /////////////////////////////////////////

    // Fallback function to prevent an address sending ether to this contract by mistake
	function()
	{
		throw;
	}

    // registers a request using request ID
    function registerRequest(int userId, int requestId)
        onlyNewRequest(requestId)
        public
    {
        Request request = requests[requestId];
        request.id = requestId;
        request.status = RequestStatus.Requested;
        request.userId = userId;

        RequestAdded(userId, requestId);
    }

    // withdraws a request using request ID
    function withdrawRequest(int userId, int requestId)
        onlyActiveRequest(requestId)
        public
    {
        Request request = requests[requestId];
        request.status = RequestStatus.Withdrawn;

        RequestWithdrawn(userId, requestId);
    }

    // get a request using request ID
    function getRequest(int requestId)
        public
        constant
        returns (int, RequestStatus, int)
    {
        Request request = requests[requestId];
        return (request.id, request.status, request.userId);
    }

    // registers a bid for a request
    function registerBid(int restaurantId, int bidId, int requestId)
        onlyActiveRequest(requestId)
        onlyNewBid(bidId)
        public
    {
        Bid bid = bids[bidId];
        bid.id = bidId;
        bid.status = BidStatus.Offered;
        bid.restaurantId = restaurantId;
        bid.requestId = requestId;

        BidAdded(restaurantId, bidId, requestId);
    }

    // withdrwas a bid for a request
    function withdrawBid(int restaurantId, int bidId, int requestId)
        onlyActiveBid(bidId)
        onlyActiveRequest(requestId)
        public
    {
        Bid bid = bids[bidId];
        bid.status = BidStatus.Withdrawn;

        BidWithdrawn(restaurantId, bidId, requestId);
    }

    function acceptBid(int restaurantId, int userId, int requestId, int bidId)
        onlyActiveRequest(requestId)
        onlyActiveBid(bidId)
        public
    {
        Request request = requests[requestId];
        request.status = RequestStatus.Fulfilled;
        Bid bid = bids[bidId];
        bid.status = BidStatus.Accepted;

        BidAccepted(bid.restaurantId, bidId, requestId);
        RequestFulfilled(userId, requestId, bidId);
    }

    // get a bid using bid ID
    function getBid(int bidId)
        public
        constant
        returns (int, BidStatus, int, int)
    {
        Bid bid = bids[bidId];
        return (bid.id, bid.status, bid.restaurantId, bid.requestId);
    }
}

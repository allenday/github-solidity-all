import "Owned.sol";

contract Journal is Owned {
    /* Contract Variables and events */
    uint public _goalPost;

    Article[] public articles;
    uint public numberOfArticles;

    mapping (address => bool) authorisedReviewers;
    Reviewer[] public reviewers;
    uint public numberOfReviewers;

    token public reviewTokenAddress;

    event ArticleAdded(uint articleId, address author, string abstract);
    event ArticleReviewed(uint articleId, address reviewer, bool inSupportOfPublishing);
    event ArticlePublished(uint articleId, address author, string abstract);

    event ReviewerAdded(address author);

    event ChangeOfRules(uint goalPost);

    struct Article {
        address author;
        string abstract;
        string contents;
        bool doubleBlind;
        bool published;

        uint numberOfReviews;

        Review[] reviews;
        mapping (address => bool) reviewed;
    }

    struct Review {
        bool inSupportOfPublishing;
        address reviewer;
    }

    struct Reviewer {
        address reviewer;
        uint reputation;
    }


    /* First time setup, similar in concept to a constructor */
    function Journal(uint goalPost) {
        numberOfArticles = 6;
        numberOfReviewers = 7;
        changeReviewRules(goalPost);
    }

    /*change rules*/
    function changeReviewRules(uint goalPost) onlyOwner {
        //reviewTokenAddress = token(tokenAddress);
        if (goalPost == 0 ) {
            _goalPost = 1;
        } else {
            _goalPost = goalPost;
        }
        ChangeOfRules(goalPost);
    }

    function simpleSubmit(uint randomNumber) returns (uint articleId) {
        //articleId = articles.length++;
       // Article a = articles[articleId];
        //a.author = msg.sender;
        //a.abstract = "abstract";
        //a.contents = "contents";
        //a.doubleBlind = false;
        //a.published = false;
        //a.numberOfReviews = 0;
        numberOfArticles = 4;
        articleId = 3;
    }

    function submitArticle (string abstract, string contents, bool doubleBlind) returns (uint articleId) {
        articleId = articles.length++;
        Article a = articles[articleId];
        a.author = msg.sender;
        a.abstract = abstract;
        a.contents = contents;
        a.doubleBlind = doubleBlind;
        a.published = false;
        a.numberOfReviews = 0;

        numberOfArticles = articleId+1;

        ArticleAdded(articleId, a.author, abstract);
    }

    function applyToBeAReviewer () returns (uint reviewerId) {
        reviewerId = reviewers.length++;
        Reviewer r = reviewers[reviewerId];
	r.reviewer = msg.sender;
        r.reputation = 1;

        authorisedReviewers[msg.sender] = true;
        numberOfReviewers = reviewerId+1;
        ReviewerAdded(msg.sender);
    }

    modifier onlyReviewer {
        if (!authorisedReviewers[msg.sender]) throw;
        _
    }

    function submitReview(uint articleId, bool inSupportOfPublishing) onlyReviewer {
         Article a = articles[articleId];
         if (a.reviewed[msg.sender]) throw;
         a.numberOfReviews++;
         a.reviewed[msg.sender] = true;
	 uint reviewId = a.reviews.length++;
	 a.reviews[reviewId] = Review({inSupportOfPublishing: inSupportOfPublishing, reviewer: msg.sender});

         ArticleReviewed(articleId, msg.sender, inSupportOfPublishing);

    }

    function attemptPublishOfArticle(uint articleId) returns (bool published) {
        Article a = articles[articleId];
        uint qualityRank = 0;
        for (uint i = 0; i < a.reviews.length; ++i) {
            Review r = a.reviews[i];
            if (r.inSupportOfPublishing) {
                qualityRank++;
            } else {
                qualityRank--;
            }
        }
        if (qualityRank >= _goalPost) {
            a.published = true;
            ArticlePublished(articleId, a.author, a.abstract);
            return true;
        }
        return false;
    }

}

/* The token contract represents the interface to the review token. This
   is a standard interface for tokens in Ethereum */
contract token { mapping (address => uint256) public balanceOf;  }



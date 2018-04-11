pragma solidity ^0.4.15;

contract Store {

  string public placeID;
  uint256 public overallScore;
  uint256 public totalScore;
  uint256 public totalReviewAmount;

  /// @param creation_blockstamp: current time when review is uploaded. Recorded for future retrival filter.
  struct Review {
    string comment;
    uint256 score;
    address uploader;
    uint256 creation_blockstamp;
  }

  event LogReviewAdded(address indexed uploader, string comment, uint256 score, uint256 blocktime);

  modifier validScore(uint256 _score) {
    require(_score >= 0 && _score <= 100);
    _;
  }

  /*
   * Public Function
   */

   /// @dev constructor
   function Store(string _placeID) public {
     placeID = _placeID;
   }

   /// @dev add a new review
   /// @param _uploader as a parameter because msg.sender would be the address of infura node.
   function addReview(string _comment, uint256 _score, address _uploader)
      public
      validScore(_score){
       
        totalReviewAmount = totalReviewAmount + 1;
        totalScore = totalScore + _score;
        overallScore = totalScore / totalReviewAmount;

        // Log New Review
        LogReviewAdded(_uploader, _comment ,_score, block.timestamp);
     }
}

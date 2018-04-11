pragma solidity ^0.4.11;

/*
@type: Library
@name: Math
@purpose: To provide a library of math functions
*/

library Math {
    uint constant public consentRadius = 13; //13 is 5% of the total range of 256

    /*
      @purpose: To generate a weak random number between 0 and the specified maximum
      @param: uint seed = seed number for the generation of a random number
      @param: uint max = the max for the range of random numbers that can be made
      @returns: The random number
    */
    function getRandom(uint seed, uint max) public constant returns(uint) { //Based on the function by alexvandesande
        return(uint(keccak256(block.blockhash(block.number-1), seed))%(max+1)); //Hashes the seed number with the last blockhash to generate a random number and shifts it into the desired range by using a modulus
    }

  // calculates possible clusters around all scores and returns the average score
  // and size of the biggest one.
  function getFinalScore(int[] data) public pure returns(int finalScore, uint largestClusterSize) {
      //get largest Cluster and its score
      int largestClusterScore;
        for(uint i = 0; i < data.length; i++) {
            uint clusterSize = 0;
            int clusterScore = 0;
            for (uint j = 0; j < data.length; j++){
                if(abs(data[i] - data[j]) <= consentRadius) {
                    clusterScore += data[j];
                    clusterSize++;
                }
            }
            if( clusterSize > largestClusterSize ||
               (clusterSize == largestClusterSize && clusterScore < largestClusterScore)) {
                largestClusterSize = clusterSize;
                largestClusterScore = clusterScore;

            }
        }
        finalScore = largestClusterScore/int(largestClusterSize);
   }

  /*
    @purpose: To calculate the proportion of stake an assessors gets back and whether
    or not the remained should be distributed to the others or not (iff they are not in
    the biggest cluster)
  */
  function getPayout(uint distance, uint stake, uint q) pure public returns(uint payout, bool dissenting){
      uint xOfRadius = (distance*10000) / consentRadius;
      //if in rewardCluster
      if (distance <= consentRadius) {
          payout = (q * stake * (10000 - xOfRadius)) / 10000 + stake;
      }
      else {
          // cap it to 20000 to prevent underflow
          uint xOf2RadiusCapped = xOfRadius > 20000 ? 20000 : xOfRadius;
          payout = (stake * (20000 - xOf2RadiusCapped)) / 20000;
          dissenting = true;
      }
  }


  function abs(int x) public pure returns(uint){
      if( x < 0 ) { return uint(-1*x); }
      else { return uint(x);}
  }
}


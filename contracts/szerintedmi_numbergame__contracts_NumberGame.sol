pragma solidity ^0.4.8;
import "./Owned.sol";
import "./nGameLib.sol";
import "./ethereum-api/usingOraclize.sol"; // github.com/oraclize/ethereum-api/oraclizeAPI.sol
import "./itMapsLib.sol";
import "./solidity-stringutils/strings.sol"; // github.com/Arachnid/solidity-stringutils/strings.sol
import "./stringUtilsLib.sol";

contract NumberGame is owned, usingOraclize  {
  /*********************************
   *
   * 1. anyone can place a guess, with a fixed amount of bet. Only one guess is accepted per account
   * 2. at a fixed time in the fute the round wil close
   * 2. the smallest number which wasn't guessed wins. the winner gets all pot (minus transaction fees, minus fees)
   * 3. if there is no number which was guessed by the everyone gets back their money (minus transaction fees, minus fee)
   *
   * - if for any unexpected tech reason not all guesses were revealed then admin can initiate a forced end (TODO: implement)
   * - if ones guess turns out to be then he/she won't get back any money (ie. it increases the total pot)
   *
   * TECH notes
   * - guesses are placed in an enrcrypted format (client side encryption, we don't have )
   * - fee
   * **************************/

    // Use itMap for all functions on the struct
    using itMapsLib for itMapsLib.itMapUintUint;
    using itMapsLib for itMapsLib.itMapUintAddress;
    using itMapsLib for itMapsLib.itMapAddressUint;
    using itMapsLib for itMapsLib.itMapUintBool;
    using nGameLib for nGameLib.Round;
    using nGameLib for nGameLib.Game;
    using nGameLib for nGameLib.ResultCalcHelper;
    using strings for *;

    /* TODO: contract is too big, need to refactor to separate contracts (and rethink libs includng nGameLib)
     TODO: deductFee() transfers the whole fee amount to owner although oraclize already deducted
            transaction fees. How to handle this in an automated way to make sure the contract has always money
     TODO: what gasPrice to use for the callback(s)?
     TODO: add admin fucntion to adjust gasLimit for callback functions
     TODO: NICE add admin users feature - certain functions can be managed only by them (addAdmin, removeAdmin. setBetAmount, revealTime, freeze etc.)
     TODO: MUST add admin switch to FREEZE contract (no bets accepted, no new game, close only by forceClose)
     TODO: MUST full code review (logic, vulnerabilities, storage/ memory / gas compsuntion)
             https://github.com/ConsenSys/smart-contract-best-practices
     TODO: sol tests
     TODO: NICE add optional nickname for bet
     TODO: NICE test coverage check
     TODO: (BIG) replace Oraclize with own service. New keypair for each round.
          would be cheaper
          Would allow to reveal all bets together + when x number of players reached
          ? which woould work better: number of people target instead of time limit? or combine?

     CHECK:  shall we check revealtime on placebet as well?
     CHECK: should we split it into multiple libraries / contractacts?
     CHECK: for potential overflows with uint additions and  with array indexes etc.
     TODO: __callback does too many things (reveal, check close, distribute and close)
              that's risky (tx size, if error happens anywhere the reveal lost etc.)
              also expensive (we need to pay the max gas fee to oraclize and they don't refund gas leftover)
              the main issue is that the round close is happening in the last reveal callback so we need to always pass
                gas to ORaclize to cover it and they don't refund
              any better way to do it? maybe split the transaction into multiple oraclize callbacks.
      CHECK: client side must check bet before encryption for correct bet.
      CHECK: do we need  version control if we have admin kill switch?
            Ie we can just change contract address on client side (or use ENS?) for new versions
            (libraries? https://medium.com/zeppelin-blog/proxy-libraries-in-solidity-79fbe4b970fd)
     CHECK: NICE shall we remove DeleteFlag from iterable maps, unecessery data
     CHECK: can we / should we flush arrays and mappings after betting closed? Does it to free up storage? better to keep it for easy audit?
     CHECK: status of Revert() EIP? Would save gas & enable much nicer error handling, eg:
              improve error handling in placeBet (no need then for verifyBet)
              (ie. we can't return error codes because that's payable so we need the throw for refund)
    */

    event e_betPlaced (uint indexed _roundId, address indexed _from, bytes32 _queryId);
    event e_betRevealed (uint indexed _roundId, address indexed _from, bytes32 _queryId, uint _betNumber);
    event e_roundClosed (uint indexed _roundId, address _winnerAddress, uint _winningNumber, uint _numberOfBets, uint _numberOfUnRevealedBets, uint _numberOfInvalidBets); // TODO: add idstibute .
    event e_roundStarted (uint indexed _roundId, uint _requiredBetAmount, uint _revealTime);
    /// TODO: change e_error to: event e_log(uint indexed _roundId, string _msg);
    event e_error(string _errorMsg);
    event e_fundsReceived (address indexed _from, uint _amount);
    event e_settingChange(uint indexed _roundId, string _settingName, uint _oldValue, uint _newValue);

    nGameLib.Game game; //  to store all game info

    // constructor
    function NumberGame() payable {
        // CHECK: do we need TLS?
        // oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);

        // For testrpc
        //      use this mnemonic with testrpc in order to have the same Oraclize address from ethereum-bridge
        //        testrpc -m "hello build tongue rack parade express shine salute glare rate spice stock" -a 10
        //      https://ethereum.stackexchange.com/questions/11383/oracle-oraclize-it-with-truffle-and-testrpc
        // TODO: how to automate deploying to testnet and testrpc w/o code change?
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        oraclize_setProof(proofType_NONE);
        game.nextRoundLength = 120 seconds;
        game.nextRoundRequiredBetAmount = 1 ether;
        game.nextRoundFee = 20000; // parts per million , ie. 10,000 = 1% */
    } // constructor

    // fallback function
    function() payable {
      if (msg.value > 0){
          e_fundsReceived (msg.sender, msg.value);
      }
    } // payable

    function getOraclizeCbAddress() constant returns (address ret) {
      return oraclize_cbAddress();
    }

/*  commented out too big contact :/    function latestRoundId() constant returns(uint _roundId) {
      // Override default getter to handle case when no round created yet
       // ie. latestRoundId = 0 but game.rounds[] is empty after contract creation

      if (game.rounds.length > 0 ) {
        return game.latestRoundId;
      } else {
        // there was no round created yet
        throw;
      }
    } */

 /*  commented out too big contact :/ function getRequiredBetAmount(uint roundId) constant returns (uint ret) {
        ret = game.rounds[roundId].requiredBetAmount;
        return ret;
    } // getRequiredBetAmount */

    function getTotalPot(uint _roundId) constant returns (uint _totalPot) {
      // returns total pot amount (fees not deducted)
      return game.rounds[_roundId].im_bets.size() * game.rounds[_roundId].requiredBetAmount;
    }

    function getWinnablePot(uint _roundId) constant returns (uint _winnablePot) {
      // returns total pot amount less fees
      return game.rounds[_roundId].im_bets.size() * game.rounds[_roundId].requiredBetAmount - getFeeAmount(_roundId);
    }

    function getFeeAmount(uint _roundId) constant returns (uint _feeAmount) {
      // returns fee based on current state
      _feeAmount = getTotalPot(_roundId) * game.rounds[_roundId].fee / 1000000;
      return _feeAmount;
    }

   /* commented out to reduce contract size: function getOraclizePrice(string _dataSource) constant returns (uint){
        return oraclize_getPrice(_dataSource) ;
    } // getOraclizePrice() */

    function getGameInfo() constant returns (uint _roundsCount, uint _latestRoundId, uint _nextRoundLength,
        uint _nextRoundRequiredBetAmount, uint _nextRoundFee ) {
        _roundsCount = game.rounds.length;
        _latestRoundId = game.latestRoundId;
        _nextRoundLength = game.nextRoundLength;
        _nextRoundRequiredBetAmount = game.nextRoundRequiredBetAmount;
        _nextRoundFee = game.nextRoundFee;
      return ( _roundsCount, _latestRoundId, _nextRoundLength,
         _nextRoundRequiredBetAmount,  _nextRoundFee );
    }

    function getRoundInfo(uint roundId) constant returns(
          bool _isActive,
          uint _requiredBetAmount, uint _revealTime, uint _roundLength,
          uint _betCount, uint _revealedBetCount,  uint _unReveleadBetCount, uint _invalidBetCount,
          address _winningAddress, uint _smallestNumber,
          uint _winnablePot, uint _fee) {
        nGameLib.Round storage currentRound  = game.rounds[roundId];
        _isActive = currentRound.isActive;

        _requiredBetAmount = currentRound.requiredBetAmount;

        _revealTime = currentRound.revealTime ;
        _roundLength = currentRound.roundLength ;

        _betCount = currentRound.im_bets.size();
        _revealedBetCount = currentRound.revealedBetCount ;
        _unReveleadBetCount = currentRound.im_bets.size() - currentRound.revealedBetCount;

        _invalidBetCount = currentRound.invalidBetCount;
        _winningAddress = currentRound.winningAddress;
        _smallestNumber = currentRound.smallestNumber;
        _winnablePot = getWinnablePot(roundId);
        _fee = currentRound.fee;

     return (_isActive,
         _requiredBetAmount,  _revealTime,  _roundLength,
         _betCount,  _revealedBetCount,   _unReveleadBetCount, _invalidBetCount
         _winningAddress, _smallestNumber,  _winnablePot, _fee);
    } // getRoundInfo()

    function getBet(uint roundId, address playerAddress) constant returns (bool _didBet,
          uint _betNumber, bool _didWin) {
       /* if _didBet == true &&_betNumber = 0 then unrevealed or revelead but invalid bet  */
       _didBet = game.rounds[roundId].im_bets.contains(playerAddress);
       _betNumber = game.rounds[roundId].im_bets.get(playerAddress);
       _didWin = (game.rounds[roundId].winningAddress == playerAddress && playerAddress != address(0));

       return (_didBet, _betNumber, _didWin);
     } // getBet()

    function setNextRoundLength(uint _nextRoundLength) onlyOwner {
        e_settingChange(game.latestRoundId, "nextRoundLength", game.nextRoundLength, _nextRoundLength);
        game.nextRoundLength = _nextRoundLength;
    }

    function setNextRoundRequiredBetAmount (uint _nextRoundRequiredBetAmount) onlyOwner {
        e_settingChange(game.latestRoundId, "nextRoundRequiredBetAmount", game.nextRoundRequiredBetAmount, _nextRoundRequiredBetAmount);
        game.nextRoundRequiredBetAmount = _nextRoundRequiredBetAmount;
    }

    function setNextRoundFee(uint32 _nextRoundFee) onlyOwner {
        e_settingChange(game.latestRoundId, "nextRoundFee", game.nextRoundFee, _nextRoundFee);
        game.nextRoundFee = _nextRoundFee;
    }

    function startNewRound() returns (uint newRoundId) {
        newRoundId = game._startNewRound();
        e_roundStarted(game.latestRoundId, game.nextRoundRequiredBetAmount, game.rounds[game.latestRoundId].revealTime);
        return newRoundId;
    }

    function verifyBet(uint roundId, uint value) constant returns (uint8 result){
      /* Helper function for placeBet. Needed because placeBet accepts value and on error need to
      throw therefore it can't return error code.
      Call from client before placing the bet to get meaningful error codes.
       Returns 1 if bet is valid
       Returns error code if error:
       2 - Invalid round id.
       3 - this round already closed.
       4 - this round already has bets revealed.
       5 - this account already placed a bet.
       6 - Ether sent is not equal to the required bet amount
       7 - Not enough ETH to cover for transaction fee (oraclize query)

       CHECK: shall we log errors with parameters included?
      */

      if ( roundId > game.latestRoundId ) {
          //e_error("Bet not saved: Invalid round id.");
          return 2;
        }

      if ( roundId != game.latestRoundId || !game.rounds[roundId].isActive) {
          //e_error("Bet not saved: this round already closed.");
          return 3;
        }

      // it shouldn't ne possible to get because isActive should be set to false when reveal starts
      if ( game.rounds[game.latestRoundId].revealedBetCount > 0 ) {
          //e_error("Bet not saved: this round already has bets revealed.");
          return 4;
      }

      if ( game.rounds[game.latestRoundId].im_bets.contains(msg.sender) ) {
          // e_error("Bet not saved: this account already placed a bet.");
          return 5;
        }

      if ( value != game.rounds[game.latestRoundId].requiredBetAmount  ) {
          // e_error("Bet not saved: Ether sent is not equal to the required bet amount");
          return 6;
      }

      uint requiredBal = oraclize_getPrice("decrypt"); // getOraclizePrice("decrypt") ;
       if ( requiredBal> this.balance) {
            // e_error("Not enough ETH to cover for transaction fee (oraclize query)" );
            return 7;
        }

      return 1;
    } // verifyBet

    function placeBet(uint roundId, string encryptedBet) payable returns (bytes32 queryId) {
      /* **********************************************************
      * Places a guess bet.
      *
      * A fixed value ("bet") must be sent with the transaction.
      *   Use getRequiredBetAmount(roundId) to get it
      * PARAMS
      * roundId: get it by instance.latestRoundId()
      *          it must be provided to ensure the the currentRound didn't change since client retrieved it
      * encryptedBet: bet encrypted on client side with Oraclize public key.
      *               format : "<guessed integer>:<random>"
      *               the guess must bigger than zero
      *               You can use this public API to encrypt the string:
      *               https://api.oraclize.it/v1/utils/encryption/encrypt
      *                 the data in the GET shoud be {"message": "8:<random>"}
      *
      * RETURNS:
      *   on success : callback query id received from Oraclize on success
      *   on error: throws without error :/.
      *             Throw needed to reject ether recevied and can't return error code with throw.
      *             Use verifyBet() before calling for error codes.
      *
      ********************************************************** */

        uint8 verifyBetResult = verifyBet(roundId, msg.value);

        if (verifyBetResult != 1 ) {
          throw;
        }

        // CHECK: error handling from oraclize_query?
        // CHECK: how gas price setting works here?
        // CHECK: is the 200k default gas safe enough? https://github.com/oraclize/ethereum-api/issues/10
        queryId = oraclize_query( game.rounds[game.latestRoundId].revealTime, "decrypt", encryptedBet, 3141592 ); // block limit: 3141592

        game.rounds[game.latestRoundId].im_bets.insert(msg.sender, 0); // store bet with 0 for now, we will reveal
                                    // later in scheduled _callback
        game.rounds[game.latestRoundId].m_queries[queryId] = msg.sender; // store query to get msg.sender in _callback
        e_betPlaced (game.latestRoundId, msg.sender, queryId);

      return queryId;
    } // placeBet

    function __callback(bytes32 queryId, string result) {
      /* ***********************************
       * Oraclize callback - reveal bid
       *     called by oraclize.it in a scheduled time at revealBidTime attribute of the round
       *     it  returns the unencrypted bid one one by one for each bid we placed
       *
       * RETURNS: nothing, it's called by oraclize
       *
       * ERRORs: it can logs errors via events, see code below
       *         (we can emmmit events as it's not payable so we don't need throw to send back money )
       *
       * NOTE: - As on errors we stop processing, the bids remains unrevealed and unrecoverable.
       *       In those cases the round won't close automatically and the admin has to manually
       *       close the round with checkAndCloseRound(forceClose=true) which will refund all bets (minus fees)
       *       - If bet is invalid we count as revelaed but keep it as 0
       * TODO: checkAndCloseRound should happen via a new callback (when all bets revealed)
       * TODO: check if callback is still for the same gameround
       *              eg. pass gameround + potential palyerADdress param to oraclize query and check here?
       *  CHECK: what if this throws ?
       *          that can lead to a round which can be closed manually only by admin (checkAndCloseRound(forced = true) .
       *          eg. bet number <1.
       *          could/should we force auto close in some of these scenerios?
       * CHECK: shall we remove items from m_queries ?
       * CHECK: could we get rid of m_queries without compromising security?
       *          Ie. if we add playeraddress to the oraclize query
       *          how we could tell which query callback is still pending?
       *  CHECK: what if a callback arrives to a round which is already closed? (test it)
       *  CHECK: if we should handle/count invalid bets differently
       *        eg.  change betNumber to int and store invalid bets as negative?
       ********************************** */

        if (msg.sender != oraclize_cbAddress()) throw;

        address playerAddress = game.rounds[game.latestRoundId].m_queries[queryId];

        // CHECK: shall we if any these errors happen:
        //              a)  remove / update bids/query & counters etc  OR
        //             b) automatically forceClose the round?
        //             c) do game.rounds[game.latestRoundId].invalidBetCount++ before return?
        if (playerAddress == address(0)) {
            // not likely  unless Oraclize cheats or bug
            e_error("A bet reveal was received but we didn't now about this bid. Reveal stopped");
            return;
        }

        if(game.rounds[game.latestRoundId].im_bets.get(playerAddress) != 0) {
            // not likely  unless Oraclize cheats or bug
            e_error("A bet reveal was received for a bid which was already revealed. Didn't overwrite first bid revelead");
            return;
        }

        if(!game.rounds[game.latestRoundId].im_bets.contains(playerAddress)) {
            // not likely  unless Oraclize cheats or bug
            e_error("A bet reveal was received for an address who didn't bet. Reveal stopped");
            return;
        }

        uint betNumber = game._revealBet(playerAddress, result);

        e_betRevealed(game.latestRoundId, playerAddress, queryId, betNumber);

        // call a non forced close (ie. it won't close if there are still unreavealed bids )
        checkAndCloseRound(false);

    } // __callback

/* moved to lib to shrink contract size
    function revealBet(address playerAddress, string result) internal returns (uint betNumber) {

        game.rounds[game.latestRoundId].revealedBetCount++; // we count as revelead (but still can be invalid)

        // extract the received decrypted parameters
        // CHECK: this cost a lot of gas, especially for longer strings. maybe limit how long we parse  somehow?

        strings.slice memory s = result.toSlice();
        strings.slice memory part;
        // part and return value is first before :
        string memory arg1 = s.split(":".toSlice(), part).toString();
        // var arg2 = s.split(".".toSlice(), part); // part and return value is next after :
        // stringToUint returns 0 if can't convert which is fine as it will be treated as invalid bet
        // CHECK: stringToUint returns 123 for "as1fsd2dsfsdf3asd" Can it cause any issue?
        // CHECK: stringUtilsLib.stringToUint this started to throw recently, no clue why.
        //betNumber = stringUtilsLib.stringToUint(arg1);
        betNumber = stringUtilsLib.parseInt(arg1, 0);

       if (betNumber > 0) {
          // reveal bid in im_bets if it's a valid betNumber
          game.rounds[game.latestRoundId].im_bets.insert(playerAddress, betNumber);

          // update results
          if (betNumber < game.rounds[game.latestRoundId].smallestNumber ||
            game.rounds[game.latestRoundId].smallestNumber == 0 && betNumber != 0 ) {
            // new winning number
            game.rounds[game.latestRoundId].smallestNumber = betNumber;
            game.rounds[game.latestRoundId].winningAddress = playerAddress;
          } else {
            if( betNumber == game.rounds[game.latestRoundId].smallestNumber) {
              // the latest winner is the same, no winner
              game.rounds[game.latestRoundId].smallestNumber = 0;
              game.rounds[game.latestRoundId].winningAddress = address(0);
            }
          }
        } else {
          // it's an invalid betNumber
          game.rounds[game.latestRoundId].invalidBetCount++;
        }

        return betNumber;

      } // revealBet
*/

    function checkAndCloseRound(bool forceClose) returns(int16 result) {
      /* **********************checkAndCloseRound************************
      *  updates result, closes round
      *         it's called after each reavel (oraclize __callback).
      *
      * PARAMETERS
      * bool forceClose: true: close even if not all bids are revealed
      *                  - only owner allowed to foreClose
      *                  - When force closed the round treated as
      *                       no winner (ie. all bets refunded  to players )
      *                  - No fee deducted (apart from gas costs already incurred) when
      *                     forceClose to avoid multiple fees deduction and charging fees when
      *                    there was a bug
      *                 It's for cases when close doesn't work any reason
      *                     ( eg. a reveal callback missed or failed for any reason)
      *
      * RETURNS: result code (updateResults success in all cases , even when error returned!)
      *           1 : no close was needed yet ( waiting for more bids to reveal )
      *           2 : all bet was revealed, round closed
      *           3 : there were unrevealed bids but forceClosed by owner
      *           TODO: 4 : round closed, all but revelead but there were invalid bets
      *           TODO: do we need  separate return code for 3& 4 combo?
      *
      *           -1 : close failed: function must be called by oraclize or owner
      *           -2 : closed failed: non owner tried to forceClose
      *           -3: close failed baceause of reveal counter crosscheck error
      *           Throws on deductFee(), refundPlayers() or payWinner() errors
      *
      * EVENTS: - e_roundClosed on success
      *         - log event emmitted if force close happenning
      *
      * NOTES:
      *       -  careful with throw from here because that cancels the reveal
      *          in the callback too which makes the bet inrecoverable
      *          (which leads to invalid round which could be closed only manually by admin)
      *         TODO: this above could be solved if we would do the close from  a new callback
      *       - We don't start a newround after close - it will be done by user before first bet
      *
      * **************************** */
      // TODO: add roundId as parameter to make sure latestRoundId didn't change since client received it
      // TODO: check against revealTime vs. now with a treshold
      //      (use functiion as that check might be called from placeBet and callback too)
      // CHECK: shall we permit admin to do forceClose before end of the round?
      //        what about if accidentally a very loooong round started?
      // CHECK: is ALWAYS no winner if forceClose ?

      // only oraclize (via __callback) & owner can close game.rounds
      if (msg.sender != oraclize_cbAddress() && msg.sender != owner) {
          return -1;
      }

      if ( msg.sender != owner && forceClose) {
          // a non owner tried to force close
          return -2;
      }

      nGameLib.Round storage currentRound = game.rounds[game.latestRoundId];
      bool isAllRevealed = (currentRound.revealedBetCount == currentRound.im_bets.size());

      if ( !isAllRevealed ) {
          if (forceClose) { // forceClose with unreavealed bids, no winner!
              e_error("Force closing round by admin despite not all bids are revealed yet.");
              currentRound.isActive = false;
              currentRound.winningAddress = address(0);
              currentRound.smallestNumber = 0;
              refundPlayers(getTotalPot(game.latestRoundId)); // refund all bet amounts (throws on error)
              result = 3;
          } else {
              // not all revealed yet - it's not an error, waiting for more reveal callbacks before we can close
             return 1;
          }
      } else {
         // all bets revelead, closing round
          currentRound.isActive = false;
          game.updateResults(game.latestRoundId);
          deductFee(); // it throws on error
          if (currentRound.winningAddress == address(0)) {
            // NO winner, refund players
            refundPlayers(getWinnablePot(game.latestRoundId)); // refund all bet amounts less fee (throws on error)
          } else {
            // there is a winner
            payWinner(); // pay winner less fees (throws on error)
          }
          result = 2;
      }

      // Close round when all went well so far

      e_roundClosed(game.latestRoundId, currentRound.winningAddress,
            currentRound.smallestNumber,
            currentRound.im_bets.size(),
            currentRound.im_bets.size() - currentRound.revealedBetCount,  //  numberOfUnrevealedBets,
            currentRound.invalidBetCount );

      return result;
    } // checkAndCloseRound

    function deductFee() internal {
      /* throws on error
        CHECK: owner.transfer() works only with solidity 0.8.10+ but truffle doesn't support that version
              follow this question: https://ethereum.stackexchange.com/questions/15749/how-do-i-specify-a-different-solidity-version-in-a-truffle-contract
              owner.transfer(getFeeAmount(game.latestRoundId)); // this throws on error */
      if (!owner.send(getFeeAmount(game.latestRoundId)) ) {
        throw;
      }
      return;
    }

    function payWinner() internal {
      // throws on error
      // CHECK: do we need duble check here that round isActive etc?
      //        (despite that it should be called only from checkAndCloseRound)
      uint payOut = getWinnablePot(game.latestRoundId);
        if (payOut > 0 ) {
        // CHECK: this works only with solidity 0.8.10+ but truffle doesn't support that version
        //        follow this question: https://ethereum.stackexchange.com/questions/15749/how-do-i-specify-a-different-solidity-version-in-a-truffle-contract
        // game.rounds[game.latestRoundId].winningAddress.transfer(getWinnablePot(game.latestRoundId)); // this throws on error
        if (!game.rounds[game.latestRoundId].winningAddress.send(payOut) ) {
          throw;
        }
      }
      return;
    }

    function refundPlayers(uint _totalRefund) internal {
      // throws on error
      uint refundAmount = _totalRefund / game.rounds[game.latestRoundId].im_bets.size();
      if (refundAmount > 0 ) {
        for (uint i = 0; i < game.rounds[game.latestRoundId].im_bets.size(); i++){
          // CHECK: .transfer() works only with solidity 0.8.10+ but truffle doesn't support that version
          //        follow this question: https://ethereum.stackexchange.com/questions/15749/how-do-i-specify-a-different-solidity-version-in-a-truffle-contract
          // game.rounds[game.latestRoundId].im_bets.getKeyByIndex(i).transfer( refundAmount);
          if (!game.rounds[game.latestRoundId].im_bets.getKeyByIndex(i).send( refundAmount) ) {
            throw;
          }
        }
      }
      return;
    }

} // NumberGame

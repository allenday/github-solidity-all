pragma solidity ^0.4.8;

import "./itMapsLib.sol";
import "./solidity-stringutils/strings.sol"; // github.com/Arachnid/solidity-stringutils/strings.sol
import "./stringUtilsLib.sol";

library nGameLib {

  /* TODO: hove to structrure this? what data/logic shall we move here? */

  using itMapsLib for itMapsLib.itMapAddressUint;
  using itMapsLib for itMapsLib.itMapUintAddress;
  using itMapsLib for itMapsLib.itMapUintBool;
  using strings for *;
  using stringUtilsLib for stringUtilsLib;

  struct Game {
      Round[] rounds;
      uint latestRoundId; /* idx in rounds, starting with 0 TODO: replace with rounds.length? */
      uint nextRoundLength; // round duration in seconds ;
      uint nextRoundRequiredBetAmount; // in Wei
      uint nextRoundFee; // parts per million , ie. 10,000 = 1%
      ResultCalcHelper resultCalcHelper;
  }

  struct Round {
       // playeraddress => bet number , bet number is 0 until revealed
      itMapsLib.itMapAddressUint im_bets;
      // callback queryId => player address : used for retrieving playerAddress at __callback
      mapping(bytes32=>address) m_queries;
      uint requiredBetAmount;
      uint revealedBetCount;
      uint invalidBetCount;
      uint smallestNumber;
      uint revealTime;
      uint roundLength;
      uint fee;
      address winningAddress;
      bool isActive;
  }

  struct ResultCalcHelper {
  /* temporary structure to calculate results - can't be in memory because can't create mappings and dynamic arrays in memory
  TODO: CHECK: could it be done without storage ??  */
  itMapsLib.itMapUintAddress im_seenOnce; // Key:betnumber -> Value:PlayerAddress
  itMapsLib.itMapUintBool im_seenMultiple; // Key:betnumber => Value:seen (bool)
                                        // mapping(uint=>bool) m_seenMultiple; would be enough to calc results
                                        // but it needs to be itmap to be able to clear after round.
}

  function _startNewRound(Game storage self) returns (uint newRoundId) {
    // CHECK: error handling (do we need to return an error code if it fails?)
    // CHECK: is it OK if anyone can call it? it needed to be able to start new round from first bet
    // This is called from the constructor or with the first bet

    if (self.rounds.length != 0 && self.rounds[self.latestRoundId].isActive) {
        // the previous one should be inactive to start a new one
       throw;
    }

    itMapsLib.itMapAddressUint memory im; // CHECK: memory???
    newRoundId = self.rounds.push( nGameLib.Round( {
        im_bets: im,
        smallestNumber: 0,
        roundLength: self.nextRoundLength,
        revealTime: now + self.nextRoundLength,
        requiredBetAmount: self.nextRoundRequiredBetAmount,
        revealedBetCount: 0,
        invalidBetCount: 0,
        fee: self.nextRoundFee,
        winningAddress: address(0),
        isActive: true
    }));

    self.latestRoundId = newRoundId -1;

    return self.latestRoundId;
  }

  function _revealBet(Game storage self, address _playerAddress, string _betString)
        internal returns (uint betNumber) {
    Round storage  currentRound = self.rounds[self.latestRoundId];
    currentRound.revealedBetCount++; // we count as revelead (but still can be invalid)

    // extract the received decrypted parameters
    // CHECK: this cost a lot of gas, especially for longer strings. maybe limit how long we parse  somehow?
    strings.slice memory s = _betString.toSlice();
    strings.slice memory part;
    // part and return value is first before :
    string memory arg1 = s.split(":".toSlice(), part).toString();
    // var arg2 = s.split(".".toSlice(), part); // part and return value is next after :
    // stringToUint returns 0 if can't convert which is fine as it will be treated as invalid bet
    // CHECK: stringToUint returns 123 for "as1fsd2dsfsdf3asd" Can it cause any issue?

    betNumber = stringUtilsLib.stringToUint(arg1);
    //betNumber = stringUtilsLib.parseInt(arg1, 0); // alterneative way to convert

   if (betNumber > 0) {
      // reveal bid in im_bets if it's a valid betNumber
      currentRound.im_bets.insert(_playerAddress, betNumber);

      // update im_seenMultiple & im_seenOnce
      if (! self.resultCalcHelper.im_seenMultiple.contains(betNumber) ) {
        if (self.resultCalcHelper.im_seenOnce.contains(betNumber)) {
          self.resultCalcHelper.im_seenOnce.remove(betNumber);
          self.resultCalcHelper.im_seenMultiple.insert(betNumber, true);
        } else {
          // first occurence, add to seenOnce
          self.resultCalcHelper.im_seenOnce.insert( betNumber, _playerAddress);
        }
      } // end if not in seenMultiple
    } else {
      // it's an invalid betNumber
      currentRound.invalidBetCount++;
    }

    return betNumber;
  } // _revealBet()

  function updateResults(Game storage self, uint _roundId) returns (bool isThereWinner) {
    Round storage _round = self.rounds[_roundId];
    ResultCalcHelper storage _resultCalcHelper = self.resultCalcHelper;
    uint numberToCheck;

    // find smallestNumber in seenOnce
    _round.winningAddress = address(0);
    _round.smallestNumber = 0;
    uint seenOnceCount = _resultCalcHelper.im_seenOnce.size();

    for( uint i=0; i < seenOnceCount; i++) {
      numberToCheck = _resultCalcHelper.im_seenOnce.getKeyByIndex(i);
      if (numberToCheck < _round.smallestNumber || _round.smallestNumber == 0) {
        _round.smallestNumber = numberToCheck;
        _round.winningAddress = _resultCalcHelper.im_seenOnce.getValueByIndex(i);
      }
    }
    // Clean up
    // CHECK: is it the best way? ie. shall we just set array lengthto zero? (im_seenOnce.clear())
    //    https://ethereum.stackexchange.com/questions/14017/solidity-how-could-i-apply-delete-to-complete-storage-ref-with-one-call
    _resultCalcHelper.im_seenOnce.destroy();
    _resultCalcHelper.im_seenMultiple.destroy();
    return (_round.smallestNumber > 0);
} // updateResults

}

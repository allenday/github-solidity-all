contract Market {

  struct Order {
    uint price;
    uint size;
    address user;
  }
  struct Option {
    int strike;
    mapping(uint => Order) buyOrders;
    uint numBuyOrders;
    mapping(uint => Order) sellOrders;
    uint numSellOrders;
  }
  struct Position {
    mapping(uint => int) positions;
    int cash;
    bool expired;
    bool hasPosition;
  }
  struct OptionChain {
    uint expiration;
    string underlying;
    uint margin;
    uint realityID;
    bytes32 factHash;
    address ethAddr;
    mapping(uint => Option) options;
    uint numOptions;
    bool expired;
    mapping(address => Position) positions;
    uint numPositions;
    uint numPositionsExpired;
  }
  mapping(uint => OptionChain) optionChains;
  uint numOptionChains;
  struct Account {
    address user;
    int capital;
  }
  mapping(uint => Account) accounts;
  uint numAccounts;
  mapping(address => uint) accountIDs; //starts at 1

  function Market() {
  }

  function addFunds() {
    if (accountIDs[msg.sender]>0) {
      accounts[accountIDs[msg.sender]].capital += int(msg.value);
    } else {
      uint accountID = ++numAccounts;
      accounts[accountID].user = msg.sender;
      accounts[accountID].capital += int(msg.value);
      accountIDs[msg.sender] = accountID;
    }
  }

  function withdrawFunds(uint amount) {
    if (accountIDs[msg.sender]>0) {
      if (int(amount)<=getFunds(msg.sender, true)) {
        accounts[accountIDs[msg.sender]].capital -= int(amount);
        cancelOrders();
        msg.sender.send(amount);
      }
    }
  }

  function getFunds(address user, bool onlyAvailable) constant returns(int) {
    if (accountIDs[user]>0) {
      if (onlyAvailable == false) {
        return accounts[accountIDs[user]].capital;
      } else {
        return accounts[accountIDs[user]].capital + getMaxLossAfterTrade(user, 0, 0, 0, 0);
      }
    } else {
      return 0;
    }
  }

  function getFundsAndAvailable(address user) constant returns(int, int) {
    return (getFunds(user, false), getFunds(user, true));
  }

  function getOptionChain(uint optionChainID) constant returns (uint, string, uint, uint, bytes32, address) {
    return (optionChains[optionChainID].expiration, optionChains[optionChainID].underlying, optionChains[optionChainID].margin, optionChains[optionChainID].realityID, optionChains[optionChainID].factHash, optionChains[optionChainID].ethAddr);
  }

  function getMarket(address user) constant returns(uint[], int[], int[], int[]) {
    uint[] memory optionIDs = new uint[](60);
    int[] memory strikes = new int[](60);
    int[] memory positions = new int[](60);
    int[] memory cashes = new int[](60);
    uint z = 0;
    for (int optionChainID=int(numOptionChains)-1; optionChainID>=0 && z<60; optionChainID--) {
      if (optionChains[uint(optionChainID)].expired == false) {
        for (uint optionID=0; optionID<optionChains[uint(optionChainID)].numOptions; optionID++) {
          optionIDs[z] = uint(optionChainID)*1000 + optionID;
          strikes[z] = optionChains[uint(optionChainID)].options[optionID].strike;
          positions[z] = optionChains[uint(optionChainID)].positions[user].positions[optionID];
          cashes[z] = optionChains[uint(optionChainID)].positions[user].cash;
          z++;
        }
      }
    }
    return (optionIDs, strikes, positions, cashes);
  }

  function getMarketTopLevels() constant returns(uint[], uint[], uint[], uint[]) {
    uint[] memory buyPrices = new uint[](60);
    uint[] memory buySizes = new uint[](60);
    uint[] memory sellPrices = new uint[](60);
    uint[] memory sellSizes = new uint[](60);
    uint z = 0;
    for (int optionChainID=int(numOptionChains)-1; optionChainID>=0 && z<60; optionChainID--) {
      if (optionChains[uint(optionChainID)].expired == false) {
        for (uint optionID=0; optionID<optionChains[uint(optionChainID)].numOptions; optionID++) {
          (buyPrices[z], buySizes[z], sellPrices[z], sellSizes[z]) = getTopLevel(uint(optionChainID), optionID);
          z++;
        }
      }
    }
    return (buyPrices, buySizes, sellPrices, sellSizes);
  }

  function expire(uint accountID, uint optionChainID, uint8 v, bytes32 r, bytes32 s, bytes32 value) {
    if (optionChains[optionChainID].expired == false) {
      if (ecrecover(sha3(optionChains[optionChainID].factHash, value), v, r, s) == optionChains[optionChainID].ethAddr) {
        uint lastAccount = numAccounts;
        if (accountID==0) {
          accountID = 1;
        } else {
          lastAccount = accountID;
        }
        for (accountID=accountID; accountID<=lastAccount; accountID++) {
          if (optionChains[optionChainID].positions[accounts[accountID].user].expired == false) {
            int result = optionChains[optionChainID].positions[accounts[accountID].user].cash / 1000000000000000000;
            for (uint optionID=0; optionID<optionChains[optionChainID].numOptions; optionID++) {
              int moneyness = getMoneyness(optionChains[optionChainID].options[optionID].strike, uint(value), optionChains[optionChainID].margin);
              result += moneyness * optionChains[optionChainID].positions[accounts[accountID].user].positions[optionID] / 1000000000000000000;
            }
            accounts[accountID].capital = accounts[accountID].capital + result;
            optionChains[optionChainID].positions[accounts[accountID].user].expired = true;
            optionChains[optionChainID].numPositionsExpired++;
          }
        }
        if (optionChains[optionChainID].numPositionsExpired == optionChains[optionChainID].numPositions) {
          optionChains[optionChainID].expired = true;
        }
      }
    }
  }

  function getMoneyness(int strike, uint settlement, uint margin) constant returns(int) {
    if (strike>=0) { //call
      if (settlement>uint(strike)) {
        if (settlement-uint(strike)<margin) {
          return int(settlement-uint(strike));
        } else {
          return int(margin);
        }
      } else {
        return 0;
      }
    } else { //put
      if (settlement<uint(-strike)) {
        if (uint(-strike)-settlement<margin) {
          return int(uint(-strike)-settlement);
        } else {
          return int(margin);
        }
      } else {
        return 0;
      }
    }
  }

  function addOptionChain(uint existingOptionChainID, uint expiration, string underlying, uint margin, uint realityID, bytes32 factHash, address ethAddr, int[] strikes) {
    uint optionChainID = 6;
    if (numOptionChains<6) {
      optionChainID = numOptionChains++;
    } else {
      for (uint i=0; i < numOptionChains && optionChainID>=6; i++) {
        if (optionChains[i].expired==true || optionChains[i].numOptions==0) {
          optionChainID = i;
        }
      }
    }
    if (optionChainID<6) {
      if (existingOptionChainID<6) {
        optionChainID = existingOptionChainID;
      } else {
        delete optionChains[optionChainID];
        optionChains[optionChainID].expiration = expiration;
        optionChains[optionChainID].underlying = underlying;
        optionChains[optionChainID].margin = margin;
        optionChains[optionChainID].realityID = realityID;
        optionChains[optionChainID].factHash = factHash;
        optionChains[optionChainID].ethAddr = ethAddr;
      }
      for (i=0; i < strikes.length; i++) {
        if (optionChains[optionChainID].numOptions<10) {
          uint optionID = optionChains[optionChainID].numOptions++;
          Option option = optionChains[optionChainID].options[i];
          option.strike = strikes[i];
          optionChains[optionChainID].options[i] = option;
        }
      }
    }
  }

  function placeBuyOrder(uint optionChainID, uint optionID, uint price, uint size) {
    if (getFunds(msg.sender, false)+getMaxLossAfterTrade(msg.sender, optionChainID, optionID, int(size), -int(size * price))>0) {
      bool foundMatch = true;
      while (foundMatch && size>0) {
        int bestPriceID = -1;
        for (uint i=0; i<optionChains[optionChainID].options[optionID].numSellOrders; i++) {
          if (optionChains[optionChainID].options[optionID].sellOrders[i].price<=price && optionChains[optionChainID].options[optionID].sellOrders[i].size>0 && (bestPriceID<0 || optionChains[optionChainID].options[optionID].sellOrders[i].price<optionChains[optionChainID].options[optionID].sellOrders[uint(bestPriceID)].price)) {
            bestPriceID = int(i);
          }
        }
        if (bestPriceID<0) {
          foundMatch = false;
        } else {
          size = orderMatchBuy(optionChainID, optionID, price, size, uint(bestPriceID));
        }
      }
      if (size>0) {
        uint orderID = 5;
        if (optionChains[optionChainID].options[optionID].numBuyOrders < 5) {
          orderID = optionChains[optionChainID].options[optionID].numBuyOrders++;
        } else {
          for (i=0; i<optionChains[optionChainID].options[optionID].numBuyOrders && (orderID>=5 || optionChains[optionChainID].options[optionID].buyOrders[orderID].size!=0); i++) {
            if (optionChains[optionChainID].options[optionID].buyOrders[i].size==0) {
              orderID = i;
            } else if (optionChains[optionChainID].options[optionID].buyOrders[i].price<price && (orderID>=5 || (optionChains[optionChainID].options[optionID].buyOrders[i].price<optionChains[optionChainID].options[optionID].buyOrders[orderID].price))) {
              orderID = i;
            }
          }
        }
        if (orderID<5) {
          optionChains[optionChainID].options[optionID].buyOrders[orderID] = Order(price, size, msg.sender);
        }
      }
    }
  }

  function placeSellOrder(uint optionChainID, uint optionID, uint price, uint size) {
    if (getFunds(msg.sender, false)+getMaxLossAfterTrade(msg.sender, optionChainID, optionID, -int(size), int(size * price))>0) {
      bool foundMatch = true;
      while (foundMatch && size>0) {
        int bestPriceID = -1;
        for (uint i=0; i<optionChains[optionChainID].options[optionID].numBuyOrders; i++) {
          if (optionChains[optionChainID].options[optionID].buyOrders[i].price>=price && optionChains[optionChainID].options[optionID].buyOrders[i].size>0 && (bestPriceID<0 || optionChains[optionChainID].options[optionID].buyOrders[i].price>optionChains[optionChainID].options[optionID].buyOrders[uint(bestPriceID)].price)) {
            bestPriceID = int(i);
          }
        }
        if (bestPriceID<0) {
          foundMatch = false;
        } else {
          size = orderMatchSell(optionChainID, optionID, price, size, uint(bestPriceID));
        }
      }
      if (size>0) {
        uint orderID = 5;
        if (optionChains[optionChainID].options[optionID].numSellOrders < 5) {
          orderID = optionChains[optionChainID].options[optionID].numSellOrders++;
        } else {
          for (i=0; i<optionChains[optionChainID].options[optionID].numSellOrders && (orderID>=5 || optionChains[optionChainID].options[optionID].sellOrders[orderID].size!=0); i++) {
            if (optionChains[optionChainID].options[optionID].sellOrders[i].size==0) {
              orderID = i;
            } else if (optionChains[optionChainID].options[optionID].sellOrders[i].price>price && (orderID>=5 || (optionChains[optionChainID].options[optionID].sellOrders[i].price>optionChains[optionChainID].options[optionID].sellOrders[orderID].price))) {
              orderID = i;
            }
          }
        }
        if (orderID<5) {
          optionChains[optionChainID].options[optionID].sellOrders[orderID] = Order(price, size, msg.sender);
        }
      }
    }
  }

  function orderMatchBuy(uint optionChainID, uint optionID, uint price, uint size, uint bestPriceID) private returns(uint) {
    uint sizeChange = min(optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].size, size);
    if (getFunds(optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].user, false)+getMaxLossAfterTrade(optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].user, optionChainID, optionID, -int(sizeChange), int(sizeChange * optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].price))>0) {
      size -= sizeChange;
      if (optionChains[optionChainID].positions[msg.sender].hasPosition == false) {
        optionChains[optionChainID].positions[msg.sender].hasPosition = true;
        optionChains[optionChainID].numPositions++;
      }
      if (optionChains[optionChainID].positions[optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].user].hasPosition == false) {
        optionChains[optionChainID].positions[optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].user].hasPosition = true;
        optionChains[optionChainID].numPositions++;
      }
      optionChains[optionChainID].positions[msg.sender].positions[optionID] += int(sizeChange);
      optionChains[optionChainID].positions[msg.sender].cash -= int(sizeChange * optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].price);
      optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].size -= sizeChange;
      optionChains[optionChainID].positions[optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].user].positions[optionID] -= int(sizeChange);
      optionChains[optionChainID].positions[optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].user].cash += int(sizeChange * optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].price);
    } else {
      optionChains[optionChainID].options[optionID].sellOrders[bestPriceID].size = 0;
    }
    return size;
  }

  function orderMatchSell(uint optionChainID, uint optionID, uint price, uint size, uint bestPriceID) private returns(uint) {
    uint sizeChange = min(optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].size, size);
    if (getFunds(optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].user, false)+getMaxLossAfterTrade(optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].user, optionChainID, optionID, int(sizeChange), -int(sizeChange * optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].price))>0) {
      size -= sizeChange;
      if (optionChains[optionChainID].positions[msg.sender].hasPosition == false) {
        optionChains[optionChainID].positions[msg.sender].hasPosition = true;
        optionChains[optionChainID].numPositions++;
      }
      if (optionChains[optionChainID].positions[optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].user].hasPosition == false) {
        optionChains[optionChainID].positions[optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].user].hasPosition = true;
        optionChains[optionChainID].numPositions++;
      }
      optionChains[optionChainID].positions[msg.sender].positions[optionID] -= int(sizeChange);
      optionChains[optionChainID].positions[msg.sender].cash += int(sizeChange * optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].price);
      optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].size -= sizeChange;
      optionChains[optionChainID].positions[optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].user].positions[optionID] += int(sizeChange);
      optionChains[optionChainID].positions[optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].user].cash -= int(sizeChange * optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].price);
    } else {
      optionChains[optionChainID].options[optionID].buyOrders[bestPriceID].size = 0;
    }
    return size;
  }

  function getTopLevel(uint optionChainID, uint optionID) private constant returns(uint, uint, uint, uint) {
    uint buyPrice = 0;
    uint buySize = 0;
    uint sellPrice = 0;
    uint sellSize = 0;
    uint watermark = 0;
    uint size = 0;
    for (uint i=0; i<optionChains[optionChainID].options[optionID].numBuyOrders; i++) {
      if (optionChains[optionChainID].options[optionID].buyOrders[i].size>0 && optionChains[optionChainID].options[optionID].buyOrders[i].price>=watermark) {
        if (optionChains[optionChainID].options[optionID].buyOrders[i].price>watermark) {
          size = 0;
          watermark = optionChains[optionChainID].options[optionID].buyOrders[i].price;
        }
        size += optionChains[optionChainID].options[optionID].buyOrders[i].size;
      }
    }
    buyPrice = watermark;
    buySize = size;
    watermark = uint(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    size = 0;
    for (i=0; i<optionChains[optionChainID].options[optionID].numSellOrders; i++) {
      if (optionChains[optionChainID].options[optionID].sellOrders[i].size>0 && optionChains[optionChainID].options[optionID].sellOrders[i].price<=watermark) {
        if (optionChains[optionChainID].options[optionID].sellOrders[i].price<watermark) {
          size = 0;
          watermark = optionChains[optionChainID].options[optionID].sellOrders[i].price;
        }
        size += optionChains[optionChainID].options[optionID].sellOrders[i].size;
      }
    }
    sellPrice = watermark;
    sellSize = size;
    return (buyPrice, buySize, sellPrice, sellSize);
  }

  function cancelOrders() {
    for (uint optionChainID=0; optionChainID<numOptionChains; optionChainID++) {
      for (uint i=0; i<optionChains[optionChainID].numOptions; i++) {
        for (uint j=0; j<optionChains[optionChainID].options[i].numBuyOrders; j++) {
          if (optionChains[optionChainID].options[i].buyOrders[j].user==msg.sender) {
            optionChains[optionChainID].options[i].buyOrders[j].size = 0;
          }
        }
        for (j=0; j<optionChains[optionChainID].options[i].numSellOrders; j++) {
          if (optionChains[optionChainID].options[i].sellOrders[j].user==msg.sender) {
            optionChains[optionChainID].options[i].sellOrders[j].size = 0;
          }
        }
      }
    }
  }

  function getMaxLossAfterTrade(address user, uint optionChainID, uint optionID, int positionChange, int cashChange) constant returns(int) {
    int totalMaxLoss = 0;
    for (uint i=0; i<numOptionChains; i++) {
      if (optionChains[i].positions[user].expired == false && optionChains[i].numOptions>0) {
        bool maxLossInitialized = false;
        int maxLoss = 0;
        for (uint s=0; s<optionChains[i].numOptions; s++) {
          int pnl = optionChains[i].positions[user].cash / 1000000000000000000;
          if (i==optionChainID) {
            pnl += cashChange / 1000000000000000000;
          }
          uint settlement = 0;
          if (optionChains[i].options[s].strike<0) {
            settlement = uint(-optionChains[i].options[s].strike);
          } else {
            settlement = uint(optionChains[i].options[s].strike);
          }
          pnl += moneySumAtSettlement(user, optionChainID, optionID, positionChange, i, settlement);
          if (pnl<maxLoss || maxLossInitialized==false) {
            maxLossInitialized = true;
            maxLoss = pnl;
          }
          pnl = optionChains[i].positions[user].cash / 1000000000000000000;
          if (i==optionChainID) {
            pnl += cashChange / 1000000000000000000;
          }
          settlement = 0;
          if (optionChains[i].options[s].strike<0) {
            if (uint(-optionChains[i].options[s].strike)>optionChains[i].margin) {
              settlement = uint(-optionChains[i].options[s].strike)-optionChains[i].margin;
            }
          } else {
            settlement = uint(optionChains[i].options[s].strike)+optionChains[i].margin;
          }
          pnl += moneySumAtSettlement(user, optionChainID, optionID, positionChange, i, settlement);
          if (pnl<maxLoss) {
            maxLoss = pnl;
          }
        }
        totalMaxLoss += maxLoss;
      }
    }
    return totalMaxLoss;
  }

  function moneySumAtSettlement(address user, uint optionChainID, uint optionID, int positionChange, uint i, uint settlement) constant returns(int) {
    int pnl = 0;
    for (uint j=0; j<optionChains[i].numOptions; j++) {
      pnl += optionChains[i].positions[user].positions[j] * getMoneyness(optionChains[i].options[j].strike, settlement, optionChains[i].margin) / 1000000000000000000;
      if (i==optionChainID && j==optionID) {
        pnl += positionChange * getMoneyness(optionChains[i].options[j].strike, settlement, optionChains[i].margin) / 1000000000000000000;
      }
    }
    return pnl;
  }

  function min(uint a, uint b) constant returns(uint) {
    if (a<b) {
      return a;
    } else {
      return b;
    }
  }
}

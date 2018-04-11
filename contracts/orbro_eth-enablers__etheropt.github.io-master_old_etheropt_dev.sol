function getOptionBuyOrders(uint optionChainID, uint optionID) constant returns(uint[], uint[]) {
  uint[] memory buyPrices = new uint[](3);
  uint[] memory buySizes = new uint[](3);
  uint z = 0;
  uint bestLevel = 10000;
  while (z<3) {
    uint watermark = 0;
    uint size = 0;
    for (uint i=0; i<optionChains[optionChainID].options[optionID].numBuyOrders; i++) {
      if (optionChains[optionChainID].options[optionID].buyOrders[i].size>0 && optionChains[optionChainID].options[optionID].buyOrders[i].price>=watermark && optionChains[optionChainID].options[optionID].buyOrders[i].price<bestLevel) {
        if (optionChains[optionChainID].options[optionID].buyOrders[i].price>watermark) {
          size = 0;
          watermark = optionChains[optionChainID].options[optionID].buyOrders[i].price;
        }
        size += optionChains[optionChainID].options[optionID].buyOrders[i].size;
      }
    }
    if (watermark>0) {
      bestLevel = watermark;
      buyPrices[z] = watermark;
      buySizes[z] = size;
    }
    z = z + 1;
  }
  return (buyPrices, buySizes);
}

function getOptionSellOrders(uint optionChainID, uint optionID) constant returns(uint[], uint[]) {
  uint[] memory sellPrices = new uint[](3);
  uint[] memory sellSizes = new uint[](3);
  uint z = 0;
  uint bestLevel = 0;
  while (z<3) {
    uint watermark = 10000;
    uint size = 0;
    for (uint i=0; i<optionChains[optionChainID].options[optionID].numSellOrders; i++) {
      if (optionChains[optionChainID].options[optionID].sellOrders[i].size>0 && optionChains[optionChainID].options[optionID].sellOrders[i].price<=watermark && optionChains[optionChainID].options[optionID].sellOrders[i].price>bestLevel) {
        if (optionChains[optionChainID].options[optionID].sellOrders[i].price<watermark) {
          size = 0;
          watermark = optionChains[optionChainID].options[optionID].sellOrders[i].price;
        }
        size += optionChains[optionChainID].options[optionID].sellOrders[i].size;
      }
    }
    if (watermark<10000) {
      bestLevel = watermark;
      sellPrices[z] = watermark;
      sellSizes[z] = size;
    }
    z = z + 1;
  }
  return (sellPrices, sellSizes);
}

function cancelOrdersOnOption(uint optionChainID, uint optionID) {
  for (uint j=0; j<optionChains[optionChainID].options[optionID].numBuyOrders; j++) {
    if (optionChains[optionChainID].options[optionID].buyOrders[j].user==msg.sender) {
      optionChains[optionChainID].options[optionID].buyOrders[j].size = 0;
    }
  }
  for (j=0; j<optionChains[optionChainID].options[optionID].numSellOrders; j++) {
    if (optionChains[optionChainID].options[optionID].sellOrders[j].user==msg.sender) {
      optionChains[optionChainID].options[optionID].sellOrders[j].size = 0;
    }
  }
}

function getMaxLoss(address user) constant returns(int) {
  int totalMaxLoss = 0;
  for (uint i=0; i<numOptionChains; i++) {
    if (optionChains[i].expired == false) {
      int maxLoss = 0;
      int pnl = optionChains[i].positions[user].cash;
      maxLoss = pnl;
      for (uint j=0; j<optionChains[i].numOptions; j++) {
        pnl += optionChains[i].positions[user].positions[j];
        if (pnl<maxLoss) {
          maxLoss = pnl;
        }
      }
      totalMaxLoss += maxLoss;
    }
  }
  return totalMaxLoss;
}

function addToOptionChain(uint optionChainID, uint[] ids, uint[] strikes, bytes32[] factHashes, address[] ethAddrs) {
  if (msg.sender==admin) {
    OptionChain optionChain = optionChains[optionChainID];
    for (uint i=0; i < strikes.length; i++) {
      uint optionID = optionChain.numOptions++;
      Option option = optionChain.options[optionID];
      option.id = ids[i];
      option.strike = strikes[i];
      option.factHash = factHashes[i];
      option.ethAddr = ethAddrs[i];
    }
  }
}

function getAvailableFunds(address user) constant returns(int) {
  if (accountIDs[user]>0) {
    return accounts[accountIDs[user]].capital + getMaxLossAfterTrade(user, 0, 0, 0, 0);
  } else {
    return 0;
  }
}

function isExpired(uint optionChainID) constant returns(bool) {
  return optionChains[optionChainID].expired;
}
function getNumOptionChains() constant returns(uint) {
  return numOptionChains;
}
function getNumOptions(uint optionChainID) constant returns(uint) {
  return optionChains[optionChainID].numOptions;
}
function getOption(uint optionChainID, uint optionID) constant returns(uint, uint, bytes32, address) {
  return (optionChains[optionChainID].options[optionID].id, optionChains[optionChainID].options[optionID].strike, optionChains[optionChainID].options[optionID].factHash, optionChains[optionChainID].options[optionID].ethAddr);
}
function getPosition(uint optionChainID, uint optionID, address user) constant returns(int) {
  return optionChains[optionChainID].positions[user].positions[optionID];
}
function getCash(uint optionChainID, address user) constant returns(int) {
  return optionChains[optionChainID].positions[user].cash;
}

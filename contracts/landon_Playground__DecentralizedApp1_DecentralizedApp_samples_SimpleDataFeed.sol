contract SimpleDataFeed {
  // note: best used in conjunction with /examples/SimpleDataFeed
  uint lastPrice;

  function update(uint newPrice) {
    lastPrice = newPrice;
  }
}

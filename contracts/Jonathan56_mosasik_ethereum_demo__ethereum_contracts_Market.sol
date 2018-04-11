pragma solidity ^0.4.4;


contract Market {
  // Participant addresses
  address[] public participants;

  // Last energy balance per participant [Wh]
  mapping (address => int) energy_balance;

  // Total production [Wh]
  int total_production = 0;

  // Total consumption [Wh]
  int total_consumption = 0;

  // Ratio between consumption and production
  int ratio = 0;

  // Total number of participants
  int public number_of_participant = 0;

  // Number of participation during a round
  int number_of_participation = 0;

  // Retail prices for buying and selling [$/Wh]
  int retail_sell_price = 100;
  int retail_buy_price = 70;

  // Retail price upper limit [%]
  int upper_ratio = 166;

  // Retail price lower limit [%]
  int lower_ratio = 100;

  // Buying price [$/Wh]
  int buying_price = 0;

  // Selling price [$/Wh]
  int selling_price = 0;

  // Minimum local selling price (above retail price)
  /*int minimum_local_selling_price = retail_buy_price * 6 / 5;*/
  int minimum_local_selling_price = 75;

  // Maximum local buying price (above retail price)
  int maximum_local_buying_price = retail_sell_price * 6 / 5;

  // Bill per participant [$]
  mapping (address => int) bill;

  /* **********
      Event
  *********** */

  event energy_posted_event(address _target, int _value);
  event participant_at_clearing_request(int _totparticipant, int _nbparticipation);
  event market_cleared_event(int _sell, int _buy, int _ratio, int _cons, int _gen);
  event bill_sent_event(address _target, int _value);

  /* **********
    Function
  *********** */

  // Add a participant to the market
  function add_participant(){
    // Add the address of the participant to the "phone book"
    participants.push(msg.sender);

    // Increment the number of participants
    number_of_participant += 1;

    // Set participant bill to zero
    bill[msg.sender] = 0;

    // Set energy balance to zero
    energy_balance[msg.sender] = 0;
  }

  // Remove a participant from the market
  function remove_participant() {
    // NOT IMPLEMENTED YET
  }

  // Broadcast energy balance
  function post_energy_balance(int amount) {
    // Set participant last energy balance
    energy_balance[msg.sender] = amount;
    energy_posted_event(msg.sender, amount);

    // Increase total production or consumption
    if (amount < 0)
      // ratio need to be a positive number, so we ABS(amount)
      total_production += -1 * amount;
    else
      total_consumption += amount;

    // Increase number of participant for the market round
    number_of_participation += 1;
  }

  // Clear the market (set the prices and send bills)
  function clear_market() {
    // Only trigger the market when everybody has participated
    require(number_of_participation >= number_of_participant);
    participant_at_clearing_request(number_of_participant, number_of_participation);

    // Reset the market participation
    number_of_participation = 0;

    // Calculate the ratio between production and consumption
    if (total_production == 0) {
      // There is no local energy but cannot be 0 so we make it 100 lower than loads
      ratio = 100000;

    } else {
      // Ratio is calulated normally with a factor 100 to avoid floats
      ratio = total_consumption * 100 / total_production;
    }

    // The network need more local production
    if (ratio >= upper_ratio) {
      // Local energy is cheap but still producer earn more than retail price
      selling_price = minimum_local_selling_price;

      // Buying price depends on the portion of local energy
      // Local energy price * ratio + retail price for the remaining energy
      buying_price = selling_price * 100 / ratio + retail_sell_price - retail_sell_price * 100 / ratio;
    }

    // The network is slowly approaching 100% local production
    // The price of buying local generation goes up
    // this encourage consumption to increase in order to avoid high prices
    if (ratio < upper_ratio && ratio > lower_ratio) {
      // Linear equation joining the minimum selling price to the maximum buying price
      int a = (minimum_local_selling_price - maximum_local_buying_price) * 100 / (upper_ratio - lower_ratio);
      int b = maximum_local_buying_price * 100 - a * lower_ratio;
      selling_price = (a * ratio + b) / 100;

      // Buying price depends on the portion of local energy and its price
      // Same equatio as previous section
      buying_price = selling_price * 100 / ratio + retail_sell_price - retail_sell_price * 100 / ratio;

      // It seems that rounding problem can make buying_price larger?
      if (buying_price > maximum_local_buying_price) {
        buying_price = maximum_local_buying_price;
      }
    }

    // Local generatio is back feeding to the main grid
    if (ratio <= lower_ratio) {
      // Buying price is at its maximum to encourage more consumption
      // to lower the price
      buying_price = maximum_local_buying_price;

      // Selling price progressively decrease as the excess power is sold
      // at a lower retail price
      selling_price = buying_price * ratio / 100 + retail_buy_price - retail_buy_price * ratio / 100;
    }

    // Event marked cleared
    market_cleared_event(selling_price, buying_price, ratio, total_consumption, total_production);

    // Reset total production and total consumption for this round
    total_consumption = 0;
    total_production = 0;

    // Send a bill to all the participants
    _bill_all_participants();
  }

  function _bill_all_participants() {
    // Loop over all the participants
    for (uint i = 0; i < participants.length; i++) {

      // Bill participant differently if they are prosumers or consumers
      if (energy_balance[participants[i]] > 0) {
        // Participant consumed power (energy_balance is positive)
        int positive_bill = buying_price * energy_balance[participants[i]];
        bill[participants[i]] += positive_bill;
        bill_sent_event(participants[i], positive_bill);

      } else {
        // Participant produced energy (energy_balance is negative)
        int negative_bill = selling_price * energy_balance[participants[i]];
        bill[participants[i]] += negative_bill;
        bill_sent_event(participants[i], negative_bill);
      }
    }
  }

  // End of the contract
}

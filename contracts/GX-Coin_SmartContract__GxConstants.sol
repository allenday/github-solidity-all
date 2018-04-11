pragma solidity ^0.4.2;

contract GxConstants {
	uint80 public MIN_GAS_FOR_MATCH_ORDER;
	uint80 public MIN_GAS_FOR_SAVE_ORDER;
	uint80 public REFUND_EXTRA_GAS;
	uint80 public INITIAL_TRADER_ETHEREUM;

	function GxConstants() {
		// gas amount 150k is tested and conservatively set, enough to do one match and raise the cancel event; 100k causes out-of-gas error
		MIN_GAS_FOR_MATCH_ORDER = 250000;

		// TODO: figure out exact amount
		// this leaves about ~49'000 gas after raising the cancellation events
		MIN_GAS_FOR_SAVE_ORDER = 200000;

        // the constant represents a lower-end estimation of the execution costs
        // for the remainder of execution.  Note that this should never result in
        // a refund greater than execution costs (or else a trader could run an
        // attack which could successfully drain all contract funds)
        REFUND_EXTRA_GAS = 29540;

        // Ether for the trader for them to start trading
        // is calculated as follows:
        //   gas costs per transaction in wei (measured on a local blockchain)
        //     buy: 178839
        //     sell: 159308
        //     sell + match: 217927
        //     cancel: 38665
        //   assume 200000 per transaction * 5 transactions = 1000000 gas
        //   1000000 gas * 50000000000 (current gas price in wei) = 50000000000000000 wei
        INITIAL_TRADER_ETHEREUM = 50000000000000000;
	}
}
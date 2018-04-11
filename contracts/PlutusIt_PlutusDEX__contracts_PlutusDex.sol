contract PlutusDex {
    enum CurrencySymbol { EUR, GBP, USD }
    //Addresses of ethereum accounts that are approved to verify bitcoin transactions,
    //, verify/perform deposit of fiat to escrow account and verify/perform deposit
    //of fiat to vdc
    mapping(address => bool) approvedTraders;

    modifier aprrovedTrader() {
      if(approvedTraders[msg.sender]) _
    }

    struct FiatDeposit {
        address trader;
        uint fiatDeposited;
        CurrencySymbol fiatSymbol;
        uint btcAsked;
        //From https://forum.ethereum.org/discussion/3139/store-bitcoin-address-in-smart-contract
        bytes20 btcAddress; //Public address to deposit the bitcoin too
    }

    mapping(address => FiatDeposit) fiatDeposits;

    uint btcTradingVolume;

    event FiatDeposited(address trader, uint fiatDeposited, CurrencySymbol fiatSymbol, uint btcAsked, bytes20 btcAddress);

    event VdcLoaded(bytes32 userVdcIban, uint fiatAmount, CurrencySymbol fiatSymbol, uint btcTradingVolume);

    function PlutusDex() {
        approvedTraders[msg.sender] = true;
        btcTradingVolume = 0;
    }

    function depositFiat(address trader, uint fiatDeposited, CurrencySymbol fiatSymbol, uint btcAsked, bytes20 btcAddress) aprrovedTrader {
        fiatDeposits[trader] = FiatDeposit(trader, fiatDeposited, fiatSymbol, btcAsked, btcAddress);
        //Emit event, to notify all plutus-users
        FiatDeposited(trader, fiatDeposited, fiatSymbol, btcAsked, btcAddress);
    }

    /**
     * Offer amount of BTC to specified trader.
     * Handling of cheapest price should all be done offchain.
     */
    function offerBtc(address trader, uint btcOffered, bytes32 userVdcIban) aprrovedTrader returns(bool result) {
        //TODO some Null check
        FiatDeposit deposited = fiatDeposits[trader];
        uint btcTraded;
        if (deposited.btcAsked < btcOffered) {
            btcTraded = btcOffered;
        } else {
            btcTraded = deposited.btcAsked;
        }
        uint fiatReceived = deposited.fiatDeposited * (btcTraded / btcOffered);
        deposited.btcAsked -= btcTraded;
        deposited.fiatDeposited -= fiatReceived;
        btcTradingVolume += btcTraded;
        //Notify user
        VdcLoaded(userVdcIban, fiatReceived, deposited.fiatSymbol, btcTradingVolume);
        return true;
    }
}

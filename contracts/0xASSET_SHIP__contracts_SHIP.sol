pragma solidity ^0.4.15;

import "./SafeMath.sol";
import "./SafeMathUtil.sol";
import "./Presale.sol";


contract SHIP {
  using SafeMath for uint256;
  using SafeMathUtil for uint256;

  struct Participant {
    uint256 balance;
    uint256 version;
    uint256 rounds;
  }

  address creator;
  uint256 public incubationDays;
  uint256 public initialDonation;
  uint256 public finalDonation;

  uint256 public phase;
  uint256 incubationStart;
  uint256 incubationEnd;
  bool pledgeEnabled;

  mapping (address => Participant) participants;
  uint256 public donatedBalance;

  address target;
  uint256 public presaleDays;
  uint256[] public caps;
  uint256 public totalRounds;
  uint256 presaleEnd;
  uint256 version;

  uint256 public committedBalance;
  mapping (uint256 => address[]) committedAddresses;

  uint256 pos;
  uint256 round;
  uint256 roundBalance;

  function SHIP(uint256 _incubationDays, uint256 _initialDonation, uint256 _finalDonation) public {
    creator = msg.sender;
    incubationDays = _incubationDays;
    initialDonation = _initialDonation;
    finalDonation = _finalDonation;
  }

  /**
   * Opens pledges & starts incubation period (only on first invocation)
   */
  function start() public {
    require(msg.sender == creator);
    if (phase == 0) {
      incubationStart = uint256(now);
      incubationEnd = incubationStart.add(incubationDays.mul(1 days));
    }
    phase = 1;
    pledgeEnabled = true;
  }

  /**
   * Pauses pledges
   */
  function pause() public {
    require(msg.sender == creator);
    pledgeEnabled = false;
  }

  /**
   * Returns the current donation percentage expressed in basis points
   */
  function currentDonation() public constant returns (uint256) {
    uint256(now).scale(incubationStart, incubationEnd, initialDonation, finalDonation);
  }

  /**
   * Pledges funds to the project, awarding a donation immediately to the creator
   */
  function pledge() public payable {
    require(phase == 1 && pledgeEnabled);

    Participant memory p = participants[msg.sender];

    uint256 donation = msg.value.basis(currentDonation());
    uint256 amt = msg.value.sub(donation);
    p.balance = p.balance.add(amt);
    donatedBalance = donatedBalance.add(donation);
  }

  /**
   * Bulk transfers collected donations to the creator
   */
  function withdrawDonations() public {
    require(msg.sender == creator);
    donatedBalance = 0;
    creator.transfer(donatedBalance);
  }

  /**
   * Sets presale terms, initiating the committment phase
   */
  function setPresale(uint256 _presaleDays, address _target, uint256[] _caps) public {
    require(msg.sender == creator);
    require(phase == 1);
    require(_target != 0x0);
    require(_caps.length > 0);

    phase = 2;
    presaleDays = _presaleDays;
    presaleEnd = uint256(now).add(presaleDays.mul(1 days));
    target = _target;
    caps = _caps;
    totalRounds = _caps.length;
    committedBalance = 0;
  }

  /**
   * Updates the presale terms, invalidating all prior committments
   */
  function changePresale(address _target, uint256[] _caps) public {
    require(msg.sender == creator);
    require(phase == 2 && uint256(now) < presaleEnd);
    require(_target != 0x0);
    require(_caps.length > 0);

    target = _target;
    caps = _caps;
    totalRounds = _caps.length;
    committedBalance = 0;
    version++;
  }

  /**
   * Committs existing and transferred funds to the presale
   */
  function commit() public payable {
    commit(totalRounds);
  }

  /**
   * Commits existing and transferred funds to the presale, participating only in the specified number of rounds
   */
  function commit(uint256 rounds) public payable {
    require(phase == 2);
    require(uint256(now) < presaleEnd);
    require(rounds > 0);

    Participant memory p = participants[msg.sender];

    require(p.balance > 0 || msg.value > 0);

    p.rounds = rounds;

    //Commits existing funds to the current presale version
    if (p.version != version) {
      p.version = version;
      committedBalance = committedBalance.add(p.balance);
      committedAddresses[version].push(msg.sender);
    }

    //Commits any new funds to the current presale version, subtracting a donation
    //Donation is applied here to disincentivise waiting until the last minute
    if (msg.value > 0) {
      uint256 donation = msg.value.basis(finalDonation);
      uint256 amt = msg.value.sub(donation);
      p.balance = p.balance.add(amt);
      donatedBalance = donatedBalance.add(donation); 
      committedBalance = committedBalance.add(amt);
    }
  }

  function startPresale() public {
    require(msg.sender == creator);
    require(phase == 2);
    require(uint256(now) >= presaleEnd);

    phase = 3;
    roundBalance = committedBalance;
  }

  /**
   * Processes a given number of presale slots
   */
  function process(uint256 count) public {
    require(msg.sender == creator);
    require(phase == 3);
    require(round < totalRounds);

    for (uint256 i = 0; i < count; i++) {
      address owner = committedAddresses[version][pos];
      Participant memory p = participants[owner];

      //Convert to zero-based
      uint256 maxRound = p.rounds - 1;

      //Ensure that the participant has elected to participate in this round, and has committed to the current presale terms
      if (round <= maxRound && p.version == version) {
        uint256 amount = p.balance;

        //If there is a cap on the current round that is less than the balance committed to this round, award a proportionate amount
        //E.g. if the cap is 1000 ETH and committed balance is 2000 ETH, each investor gets 50% of their funds committed
        if (caps[round] > 0 && caps[round] < roundBalance)
          amount = amount.mul(caps[round]).div(roundBalance);

        //Subtract amount from total & participant balance
        committedBalance -= amount;
        p.balance -= amount;

        //If this is the last round the investor will be participating in, take their remaining funds out of the committedBalance total 
        //so it doesn't carry over to the next round
        if (round == maxRound && p.balance > 0)
          committedBalance -= p.balance;

        //Execute the presale (TRUSTED CONTRACT)
        Presale(target).purchasePresale.value(amount)(owner, round);
      }

      pos = pos.add(1);

      if (pos == committedAddresses[version].length) {
        //Start a new round, and set the balance for the next round to what is left in the committedBalance
        pos = 0;
        round++;
        roundBalance = committedBalance;

        if (round == totalRounds) {
          phase = 4;
          //Signal the end of the presale (TRUSTED CONTRACT)
          Presale(target).onPresaleComplete();
          return;
        }
      }
    }
  }

  /**
   * Withdraw any pledged funds
   * Funds cannot be withdrawn during incubation, committment or presale
   */
  function refund() public {
    require((phase == 1 && uint256(now) > incubationEnd) || phase == 4);
    require(participants[msg.sender].balance > 0);

    uint256 balance = participants[msg.sender].balance;
    participants[msg.sender].balance = 0;

    msg.sender.transfer(balance);
  }
}

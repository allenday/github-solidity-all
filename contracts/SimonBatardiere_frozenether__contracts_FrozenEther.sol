/**
 * @title Smart contract for the Frozen Ether service.
 * @author Simon Batardiere
 *
 * @notice
 * For information about the license, see LICENSE file.
 *
 * The FrozenEther smart contract is a contract present in the Ethereum blockchain to implement the Frozen Ether
 * service. It permits to any user to store temporarily Ether in this contract, and give back it after a defined
 * period. The particularity of this contract is that the withdraw operation is forbidden during whole the duration
 * specified when the Ether will stored in the contract. This is called the frozen state.
 *
 * The contract can store many account for each user, and there is only one contract for all users. Given that each
 * user can owns more than one account, the account is identify with an unique identifier (for a given user, two users
 * can use same identifiers). Each account permits for an user to store some Ether and blocks it for a given duration.
 * Two differents account owned by one user can have different duration for their frozen states.
 *
 * To sum up, the goal of this smart contract is to block some Ether. No one - even the sender - can withdraw this
 * Ether during the frozen state. After that, the sender (and only him) can give back its Ether.
 *
 * Global opration:
 * - Create a new account.
 *
 * Operations always allowed on an account:
 * - Get how many Ether is stored in the account.
 * - Get how long is left before the end of the frozen state.
 * - Lengthen the frozen state duration: if the account is in frozen state, then the time is added to the current
 *   duration, else the account goes back in the frozen state for the specified duration.
 *
 * Operations allowed only during frozen state of an account:
 * - Deposit some Ether on the account.
 *
 * Operations allowed only when an account is not in the frozen state:
 * - Withdraw some Ether from the account. Account is automatically destroyed if it become empty.
 *
 * Events:
 * - New account is created.
 * - Existing account is destroyed.
 * - Someone desposits some Ether on an account.
 * - Someone withdraws some Ether from an account.
 * - Someone lengthen the frozen state duration of an account.
 *
 * API of this smart contract only allow account's owner to get information about this account. A user cannot retreive
 * informations about accounts owned by other users. But remember that limitation is only implemented in the API of the
 * smart contract: everyone can read datas stored in the Ethereum blockchain and analyse the transactions.
 */
pragma solidity ^0.4.0;

contract FrozenEther {
	/**
	 * @dev Account object. FrozenEther contract will manipulate these objects to save the state for each accounts.
	 */
	struct Account {
		/**
		 * @dev Expiration date, to know if the account is in the frozen state (i.e. account.expire < now) or
		 *      not. No withdraw is allowed during the frozen state. Moreover, if expire's value is 0, it means
		 *      that the account doesn't exist.
		 */
		uint expire;

		/**
		 * @devAmount of Wei stored in this account.
		 */
		uint amount;
	}

	/**
	 * @dev State variable which is a mapping of mapping of account. Each user (address) can owned a collection of
	 *      accounts, identified thanks to an unique identifier choosen arbitrarily.
	 */
	mapping (address => mapping (uint => Account)) private accounts;

	/**
	 * @notice Event generate when an account is created.
	 * @param owner Address of the account's owner.
	 * @param id Identifier of the account, which is unique for one owner.
	 * @param amount Amount of Wei which are deposited on the account.
	 */
	event Create(address owner, uint id, uint amount);

	/**
	 * @notice Event generate when an account is destroyed.
	 * @param owner Address of the account's owner.
	 * @param id Identifier of the account, which is unique for one owner.
	 */
	event Destroy(address owner, uint id);

	/**
	 * @notice Event generated when a deposit operation is performed on an account.
	 * @param owner Address of the account's owner.
	 * @param id Identifier of the account, which is unique for one owner.
	 * @param amount Amount of Wei which are deposited on the account.
	 */
	event Deposit(address owner, uint id, uint amount);

	/**
	 * @notice Event generated when a whithdraw operation is performed on an account.
	 * @param owner Address of the account's owner.
	 * @param id Identifier of the account, which is unique for one owner.
	 * @param amount Amount of Wei which are withdrawed from the account.
	 */
	event Withdraw(address owner, uint id, uint amount);

	/**
	 * @notice Event generated when the frozen state duration is extended on an account.
	 * @param owner Address of the account's owner.
	 * @param id Identifier of the account, which is unique for one owner.
	 * @param duration Duration in seconds added to the frozen state.
	 */
	event Freeze(address owner, uint id, uint duration);

	/**
	 * @notice Contract constructor.
	 */
	function FrozenEther() {
	}

	/**
	 * @notice Fallback function. Does nothing expect disallow Ether deposit.
	 */
	function () {
		throw;
	}

	/**
	 * @notice Tell if the account already exists or not.
	 * @param id Identifier of the account, which is unique for one user.
	 * @return True if the account exists, else false.
	 */
	function isExist(uint id) public constant returns(bool) {
		return isAccountExist(accounts[msg.sender][id]);
	}

	/**
	 * @notice Get the remaining time before withdraw is allowed on the account (frozen state) owned by the sender
	 *         and identify by the identifier.
	 * @param id Identifier of the account, which is unique for one user.
	 * @return Remaining time in second, or 0 if withdraw is allowed. Return also 0 if the account doesn't exist.
	 */
	function remainingTime(uint id) public constant returns(uint) {
		return remainingAccountTime(accounts[msg.sender][id]);
	}

	/**
	 * @notice Get the amount of Wei stored on the account owned by the sender and identify by the identifier.
	 * @param id Identifier of the account, which is unique for one user.
	 * @return Amount of Wei stored in the account, or 0 if the account doesn't exist.
	 */
	function amount(uint id) public constant returns(uint) {
		return accounts[msg.sender][id].amount;
	}

	/**
	 * @notice Create a new account to frozen some Ether during a laps of time. The new account is owned by the
	 *         sender and identify by the identifier. This identifier must be unused for this specific sender (but
	 *         two different users can use the same identifier).
	 * @param id Identifier of the account, which is unique for one user.
	 * @param duration Duration is seconds during the account is frozen. No withdraw is allowed during the frozen
	 *                 state.
	 * @return True if success, else false.
	 */
	function create(uint id, uint duration) public payable returns(bool) {
		Account account = accounts[msg.sender][id];

		if (!createAccount(account, duration, msg.value)) {
			throw;
		}
		Create(msg.sender, id, account.amount);
		return true;
	}

	/**
	 * @notice Deposit some Ether on an existing account owned by the sender and identify by the idetnifier. The
	 *         account must exist and must be still frozen.
	 * @param id Identifier of the account, which is unique for one user.
	 * @return True if success, else false.
	 */
	function deposit(uint id) public payable returns(bool) {
		Account account = accounts[msg.sender][id];

		if (msg.value == 0) {
			return false;
		}
		if (!depositOnAccount(account, msg.value)) {
			throw;
		}

		Deposit(msg.sender, id, msg.value);
		return true;
	}

	/**
	 * @notice Withdraw some Ether from an existing account owned by the sender and identify by the identifier.
	 * @param id Identifier of the account, which is unique for one user.
	 * @param amount Amount of Wei to withdraw from the account. If this amount is greater than the balance of the
	 *               account, this function withdraw all available Wei, not more.
	 * @return True if success, else false.
	 */
	function withdraw(uint id, uint amount) public returns(bool) {
		Account account = accounts[msg.sender][id];
		uint value = 0;

		value = withdrawFromAccount(account, amount);
		if (value == 0) {
			return false;
		}

		if (!msg.sender.send(value)) {
			throw;
		}

		Withdraw(msg.sender, id, value);
		if (account.amount == 0) {
			destroyAccount(account);
			Destroy(msg.sender, id);
		}
		return true;
	}

	/**
	 * @notice Extend the duration of the frozen state, means that no withdraw will be allowed for longer.
	 * @param id Identifier of the account, which is unique for one user.
	 * @param duration Duration is seconds which will be added to the frozen state. No withdraw is allowed during
	 *                 the frozen state. No negative value is allowed, you cannot reduce the frozen state duration!
	 *                 If the account is still in frozen state, the duration is added at the current duration, else
	 *                 the account is re-freeze for the specified duration.
	 * @return True if success, else false.
	 */
	function lenghtenFrozenState(uint id, uint duration) public returns(bool) {
		Account account = accounts[msg.sender][id];

		if (!lenghtenAccountFrozenState(account, duration)) {
			return false;
		}

		Freeze(msg.sender, id, duration);
		return true;
	}

	/**
	 * @notice Test if the account exists (i.e. is created) or not.
	 * @param account Account object which is manipulated.
	 * @return True if the account exists, else false.
	 */
	function isAccountExist(Account storage account) internal constant returns(bool) {
		return (account.expire != 0);
	}

	/**
	 * @notice Test if the account is in frozen state (i.e. not expired) or not.
	 * @param account Account object which is manipulated.
	 * @return True if the account expired, else false. And expired account means that wihdraw is allowed from it.
	 */
	function isAccountExpired(Account storage account) internal constant returns(bool) {
		return (account.expire < now);
	}

	/**
	 * @notice Get the remaining time before withdraw is allowed on the account (frozen state).
	 * @param account Account object which is manipulated.
	 * @return Remaining time in second, or 0 if withdraw is allowed. Return also 0 if the account doesn't exist.
	 */
	function remainingAccountTime(Account storage account) internal constant returns(uint) {
		uint time = 0;

		if (now < account.expire) {
			time = account.expire - now;
		}
		return time;
	}

	/**
	 * @notice Create a new account, and initialize it.
	 * @param account Account object which is manipulated.
	 * @param duration Duration is seconds during the account is frozen. No withdraw is allowed during the frozen
	 *                 state.
	 * @param amount Amount of Wei to deposit on the account.
	 * @return True if success, else false.
	 */
	function createAccount(Account storage account, uint duration, uint amount) internal returns(bool) {
		if (isAccountExist(account)) {
			return false;
		}
		account.expire = now + duration;
		if (account.expire < now) {
			return false;
		}
		account.amount = amount;
		return true;
	}

	/**
	 * @notice If the account is empty, then this function will destroy it. A destroyed account is just an account
	 *        with expire equal to 0.
	 * @param account Account object which is manipulated.
	 */
	function destroyAccount(Account storage account) internal {
		if (account.amount == 0) {
			account.expire = 0;
		}
	}

	/**
	 * @notice Deposit some Ether on an account. Deposit Ether is allowed only on an Account which is still frozen.
	 * @param account Account object which is manipulated.
	 * @param amount Amount of Wei to deposit on the account.
	 * @return True if success, else false.
	 */
	function depositOnAccount(Account storage account, uint amount) internal returns(bool) {
		if (!isAccountExist(account)) {
			return false;
		}
		if (isAccountExpired(account)) {
			return false;
		}
		account.amount += amount;
		return true;
	}

	/**
	 * @notice Withdraw some Ether from an account. If the account is empty after the withdraw, the account is
	 *        destroyed.
	 * @param account Account object which is manipulated.
	 * @param amount Amount of Wei to withdraw from the account. If this amount is greater than the balance of the
	 *               account, this function withdraw all available Wei, not more.
	 * @return Amount of Wei which are withdrawed from the account, or 0 if failure.
	 */
	function withdrawFromAccount(Account storage account, uint amount) internal returns(uint) {
		uint value;

		if (!isAccountExist(account)) {
			return 0;
		}
		if (!isAccountExpired(account)) {
			return 0;
		}

		value = amount < account.amount ? amount : account.amount;
		account.amount -= value;
		return value;
	}

	/**
	 * @notice Extend the duration of the frozen state, means that no withdraw will be allowed for longer. Do not
	 *        send Ether with this function, or the call will throw an execption.
	 * @param account Account object which is manipulated.
	 * @param duration Duration is seconds which will be added to the frozen state. No withdraw is allowed during
	 *                 the frozen state. No negative value is allowed, you cannot reduce the frozen state duration!
	 *                 If the account is still in frozen state, the duration is added at the current duration, else
	 *                 the account is re-freeze for the specified duration.
	 * @return True if success, else false.
	 */
	function lenghtenAccountFrozenState(Account storage account, uint duration) internal returns(bool) {
		if (!isAccountExist(account)) {
			return false;
		}
		if (isAccountExpired(account)) {
			account.expire = now + duration;
			if (account.expire < now) {
				return false;
			}
		} else {
			account.expire += duration;
			if (account.expire < duration) {
				return false;
			}
		}
		return true;
	}
}


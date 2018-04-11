/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
contract Owned {

    address internal owner;

    event OwnedEvent(address from, uint256 mode, uint256 id);

    function Owned() {
        OwnedEvent(msg.sender, 6, 0);
        owner = msg.sender;
    }

    modifier onlyowner {
        OwnedEvent(msg.sender, 6, 1);
        if (msg.sender == owner) {
            OwnedEvent(owner, 6, 2);
            _
        }
    }
}

contract Killable {
    function kill() public returns (bool success);
}

contract Mortal is Owned {

    function kill() onlyowner public returns (bool success) {
        suicide(owner);
        return true;
    }
}

contract Minter is Mortal {

    uint256 private supply;

    event MinterEvent(address from, uint256 mode, uint256 id, uint256 supply);

    function mint(uint256 amount) internal returns (bool success) {

        MinterEvent(msg.sender, 1, 0, supply);

        uint256 temp = supply + amount;
        if (temp < supply) {
            MinterEvent(msg.sender, 1, 1, supply);
            return false;
        }

        supply = temp;

        MinterEvent(msg.sender, 1, 2, supply);

        return true;
    }

    function unmint(uint256 amount) internal returns (bool success) {
        if (supply < amount) {
            return false;
        }

        supply -= amount;
        return true;
    }

    function kill() onlyowner public returns (bool success) {
        if (supply != 0) {
            return false;
        }

        return super.kill();
    }
}

contract Banknote is Killable {

    event BanknoteEvent(address from, uint256 mode, uint256 id);

    address public issuer;
    address private holder;

    uint256 public faceValue;

    function Banknote(address _centralBank, uint256 _faceValue) public {
        issuer = _centralBank;
        holder = _centralBank;
        faceValue = _faceValue;
    }

    function transfer(address to) public returns (bool success) {

        logging(2);
        BanknoteEvent(to, 3, 2);
        /*
            Prevent transfer banknotes which don't belong to transaction sender.
        */
        if (msg.sender != holder) {
            logging(3);
            BanknoteEvent(to, 3, 3);
            return false;
        }

        holder = to;

        logging(4);
        BanknoteEvent(to, 3, 4);

        /*
            If banknote is returned to central bank, destroy it.
        */
        if (holder == issuer) {
            logging(5);
            BanknoteEvent(to, 3, 5);
            CentralBank centralBank = CentralBank(issuer);
            centralBank.destroy(this);
        }
    }

    function change(uint256[] _faceValues) public returns (address[]) {

        logging(10);

        /*
            Prevent change banknotes which don't belong to transaction sender.
        */
        if (msg.sender != holder) {
            logging(11);

            address[] unchanged;
            unchanged.length = 1;
            unchanged[0] = this;
            return unchanged;
        }

        logging(12);

        holder = issuer;

        logging(13);

        CentralBank centralBank = CentralBank(issuer);

        logging(14);

        /* array of addresses cannot be returned (?) */
        centralBank.change(this, _faceValues);

        logging(15);
    }

    function mine() public returns (bool yes) {
        logging(0);
        return holder == msg.sender;
    }

    function returned() public returns (bool yes) {
        logging(1);
        return issuer == holder;
    }

    function kill() public returns (bool) {
        logging(6);
        if (!returned()) {
            logging(7);
            return false;
        }

        logging(8);
        suicide(issuer);

        logging(9);
        return true;
    }

    function logging(uint256 _id) private {
        BanknoteEvent(this, 3, _id);
        BanknoteEvent(msg.sender, 3, _id);
        BanknoteEvent(holder, 3, _id);
        BanknoteEvent(issuer, 3, _id);
    }
}

contract CentralBank is Minter {

    /*
        Keeps all minted banknotes and their face values.
    */
    mapping (address => uint256) private banknotes;

    event CentralBankEvent(address from, uint256 mode, uint256 id);

    function print(uint256 _faceValue) private returns (address _banknote) {

        CentralBankEvent(msg.sender, 2, 0);

        if (!super.mint(_faceValue)) {
            CentralBankEvent(msg.sender, 2, 1);
            return 0;
        }

        CentralBankEvent(msg.sender, 2, 2);

        Banknote banknote = new Banknote(this, _faceValue);

        CentralBankEvent(msg.sender, 2, 3);
        CentralBankEvent(banknote, 2, 3);

        banknotes[banknote] = _faceValue;

        CentralBankEvent(msg.sender, 2, 4);

        return banknote;
    }

    function destroy(address _banknote) public returns (bool success) {

        if (!genuine(_banknote)) {
            return false;
        }

        Banknote banknote = Banknote(_banknote);

        /*
            Central bank does not destroy a banknote or another contract which it did not issued.
        */
        if (owner != banknote.issuer()) {
            return false;
        }

        /*
            Central bank cannot destroy banknote which it does not hold.
        */
        if (!banknote.returned()) {
            return false;
        }

        banknotes[banknote] = 0;

        super.unmint(banknote.faceValue());

        banknote.kill();

        return true;
    }

    function destroy(address[] _banknotes) public returns (bool success) {
        for (uint256 i = 0; i < _banknotes.length; ++i) {
            address banknote = _banknotes[i];

            if (banknote != 0) {
                destroy(banknote);
            }
        }
    }

    function genuine(address _banknote) constant public returns (bool yes) {
        return banknotes[_banknote] != 0;
    }

    function issue(uint256 _faceValue, address _holder) onlyowner public returns (address _banknote) {

        CentralBankEvent(msg.sender, 2, 5);

        address fresh = print(_faceValue);

        CentralBankEvent(msg.sender, 2, 6);

        if (fresh == 0) {
            CentralBankEvent(msg.sender, 2, 7);
            return 0;
        }

        Banknote banknote = Banknote(fresh);

        CentralBankEvent(msg.sender, 2, 8);

        banknote.transfer(_holder);

        CentralBankEvent(msg.sender, 2, 9);

        return banknote;
    }

    function change(address _banknote, uint256[] _faceValues) public returns (address[]) {

        if (!genuine(_banknote)) {
            return unchanged(_banknote);
        }

        Banknote banknote = Banknote(_banknote);
        uint256 faceValue = banknote.faceValue();

        /*
            Only banknote holder can ask for change.
        */
        if (!banknote.mine()) {
            return unchanged(_banknote);
        }

        /* assert msg.sender == banknote.holder. */

        uint256 length = _faceValues.length;

        uint256 sum = 0;
        for (uint256 i = 0; i < length; ++i) {
            sum += _faceValues[i];
        }

        if (sum > faceValue) {
            return unchanged(_banknote);
        }

        uint256 reminder = faceValue - sum;

        if (!destroy(_banknote)) {
            banknote.transfer(msg.sender);
            return unchanged(_banknote);
        }

        address[] banknotes;

        if (reminder == 0) {
            banknotes.length = _faceValues.length;
        } else {
            banknotes.length = _faceValues.length + 1;
        }

        for (uint256 j = 0; j < length; ++j) {
            address hot = print(_faceValues[j]);

            if (hot == 0) {
                destroy(banknotes);
                banknote.transfer(msg.sender);
                return unchanged(_banknote);
            }

            banknotes[j] = hot;
        }

        if (reminder != 0) {
            address hotter = print(reminder);

            if (hotter == 0) {
                destroy(banknotes);
                banknote.transfer(msg.sender);
                return unchanged(_banknote);
            }

            banknotes[_faceValues.length] = hotter;
        }

        return banknotes;
    }

    function unchanged(address _banknote) private returns (address[] _unchanged) {
        address[] unchanged;
        unchanged.length = 1;
        unchanged[0] = _banknote;
        return unchanged;
    }
}

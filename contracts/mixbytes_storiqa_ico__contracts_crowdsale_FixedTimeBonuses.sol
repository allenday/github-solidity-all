pragma solidity 0.4.15;


library FixedTimeBonuses {

    struct Bonus {
        uint endTime;
        uint bonus;
    }

    struct Data {
        Bonus[] bonuses;
    }

    /// @dev validates consistency of data structure
    /// @param self data structure
    /// @param shouldDecrease additionally check if bonuses are decreasing over time
    function validate(Data storage self, bool shouldDecrease) internal constant {
        uint length = self.bonuses.length;
        require(length > 0);

        Bonus storage last = self.bonuses[0];
        for (uint i = 1; i < length; i++) {
            Bonus storage current = self.bonuses[i];
            require(current.endTime > last.endTime);
            if (shouldDecrease)
                require(current.bonus < last.bonus);
            last = current;
        }
    }

    /// @dev get ending time of the last bonus
    /// @param self data structure
    function getLastTime(Data storage self) internal constant returns (uint) {
        return self.bonuses[self.bonuses.length - 1].endTime;
    }

    /// @dev validates consistency of data structure
    /// @param self data structure
    /// @param time time for which bonus must be computed (assuming time <= getLastTime())
    function getBonus(Data storage self, uint time) internal constant returns (uint) {
        // TODO binary search?
        uint length = self.bonuses.length;
        for (uint i = 0; i < length; i++) {
            if (self.bonuses[i].endTime >= time)
                return self.bonuses[i].bonus;
        }
        assert(false);  // must be unreachable
    }
}

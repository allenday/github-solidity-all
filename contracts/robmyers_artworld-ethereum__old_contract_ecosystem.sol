/*
  TODO:
  * Multiple ownership and ownership levels. Add/remove owners.
    Or Reddit-style can't remove higher-up admins.
    No, this is an external problem. Just allow owners to change and then if
    someone implements a democratic etc. contract, make that the owner.
*/


/*
  A policy is how we decide whether/if something should happen.
  A strategy is how we choose what/how something should happen.
*/

/*
   A set of properties with 32 character string or 32-bit signed integer values.
   Strings and ints are stored separately.
*/

contract Tags {
    address owner;

    mapping (bytes32 => int32) intValues;
    mapping (bytes32 => bytes32) stringValues;

    modifier onlyowner { if (msg.sender == owner) _ }

    function Tags () {
        owner = msg.sender;
    }

    function addStringTag (bytes32 name, bytes32 value) public onlyowner {
        stringValues[name] = value;
    }

    function addIntTag (bytes32 name, int32 value) public onlyowner {
        intValues[name] = value;
    }

    function compareStringValue (bytes32 tag, bytes32 value, byte operator)
        public returns (int score) {
        score = 0;
        if (operator == '=') {
            if (value == stringValues[tag]) {
                score = 1;
            } else {
                score = -1;
            }
        } else if (operator == '!') {
            if (value != stringValues[tag]) {
                score = 1;
            } else {
                score = -1;
            }
        }
    }

    function compareIntValue (bytes32 tag, int value, byte operator)
        public returns (int score) {
        score = 0;
        if (operator == '=') {
            if (value == intValues[tag]) {
                score = 1;
            } else {
                score = -1;
            }
        } else if (operator == '!') {
            if (value != intValues[tag]) {
                score = 1;
            } else {
                score = -1;
            }
        } else if (operator == '>') {
            if (value > intValues[tag]) {
                score = 1;
            } else {
                score = -1;
            }
        } else if (operator == '<') {
            if (value < intValues[tag]) {
                score = 1;
            } else {
                score = -1;
            }
        }
    }
}

/*
  A set of values to compare with the values of a set of tags.
  We can compare equality or inequality (and more relationships for numbers)
  so we need something other than just another set of tags to compare.
*/

contract TagsComparator {
    struct IntComparator {
        bytes32 tag;
        int32 value;
        byte operator;
    }

    struct StringComparator {
        bytes32 tag;
        bytes32 value;
        byte operator;
    }

    StringComparator[] stringComparators;
    IntComparator[] intComparators;

    function addIntComparison (bytes32 tag, int32 value, byte operator)
        public {
        IntComparator comp = intComparators[intComparators.length];
        comp.tag = tag;
        comp.value = value;
        comp.operator = operator;
    }

    function addStringComparison (bytes32 tag, bytes32 value, byte operator)
        public {
        StringComparator comp = stringComparators[stringComparators.length];
        comp.tag = tag;
        comp.value = value;
        comp.operator = operator;
    }

    function compareIntValues (Tags tags) private returns (int score) {
        for (uint i = 0; i < intComparators.length; i++) {
            score += tags.compareIntValue(intComparators[i].tag,
                                             intComparators[i].value,
                                             intComparators[i].operator);
        }
        return score;
    }

    function compareStringValues (Tags tags) private returns (int score) {
        for (uint i = 0; i < stringComparators.length; i++) {
            score += tags.compareStringValue(stringComparators[i].tag,
                                             stringComparators[i].value,
                                             stringComparators[i].operator);
        }
        return score;
    }

    function compare (address tagsAddress) external returns (int score) {
        score = 0;
        Tags tags = Tags(tagsAddress);
        score += compareIntValues(tags);
        score += compareStringValues(tags);
    }
}

/*
  A Vector of addresses.
  While we wait for multiple returns, the invalid index value is uint(-1)
*/

contract Container {
    address[] items;

    function indexOf (address item) internal returns (uint index) {
        index = uint(-1);
        for (uint i = 0; i < items.length; i++) {
            if (items[i] == item) {
                index = i;
                break;
            }
        }
    }

    function add (address item) internal returns (bool added) {
        uint index = indexOf(item);
        added = (index == uint(-1));
        if(! added) {
            items[items.length] = item;
        }
    }

    function remove (address item) internal returns (bool removed) {
        uint index = indexOf(item);
        removed = (index != uint(-1));
        if(removed) {
            // Roll down the remaining values
            for (uint i = index; i < items.length - 1; i++) {
                items[i] = items[i + 1];
            }
            // then truncate the array
            items.length = items.length - 1;
        }
    }
}

/*
  An referable, ownable, locatable thing.
*/

contract Entity {
    address owner;
    bytes32 uri;
    bytes32 title;
}

/*
  The representation of an artwork.
  If an artwork is unique, edition size is 1.
*/

contract Artwork is Entity, Container {
    int showprice;
    int16 editionSize = 10;

    // Function to decide whether to accept a show offer
    // Function to decide whether to accept a collection offer
}

/*
  A base class for places an artwork might be.
*/

contract Locale is Entity, Container {
    int collectionSize;
    int currentCollectionSize;
    mapping (uint => address) curators;

    // Function to decide
}

contract Show is Locale {
}

contract Collection is Locale {
}

// No. This is redundant. Just have unowned edition instances set to zero

contract Studio is Locale {
}

contract Review {
    int range;
    bytes32 title;
    struct Rating {
        int score;
        bytes32 comment;
    }
    Locale subject;
    mapping (address => Rating) reviews;
}

contract Competition {
}

contract Award {
    struct Year {
        int date;
        address[] entrants;
        address winner;
        bytes32 comment;
    }
}

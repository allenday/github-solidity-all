/**
 * @title SmartBadges
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract SmartBadges {

    struct Badge {
        address owner;
        string title;
        string description;
        string url;
        BadgeLevel[] levels;
    }

    struct BadgeLevel {
        string title;
        string description;
        bytes image;
    }

    struct Awarding {
        bool revokable;
        bool revoked;
        uint time;
        uint expiration;
        uint level;
    }

    mapping (bytes32 => Badge) badges;
    mapping (address => mapping (bytes32 => Awarding)) accountBadgeAwardings;

    mapping (address => bytes32[]) accountBadges;

    event AwardBadge(address indexed account, bytes32 indexed badgeHash, uint level);
    event RevokeBadge(address indexed account, bytes32 indexed badgeHash);

    modifier isOwner(bytes32 badgeHash) {
        if (badges[badgeHash].owner != msg.sender) {
            throw;
        }
        _
    }

    function createBadge(string title, string description, string url) external returns (bytes32 badgeHash) {
        badgeHash = sha3(this, msg.sender, msg.data);
        Badge badge = badges[badgeHash];
        badge.owner = msg.sender;
        badge.title = title;
        badge.description = description;
        badge.url = url;
    }

    function getBadge(bytes32 badgeHash) constant external returns (address owner, string title, string description, string url, uint levels) {
        Badge badge = badges[badgeHash];
        owner = badge.owner;
        title = badge.title;
        description = badge.description;
        url = badge.url;
        levels = badge.levels.length;
    }

    function setBadgeLevel(bytes32 badgeHash, uint level, string title, string description, bytes image) isOwner(badgeHash) external {
        Badge badge = badges[badgeHash];
        if (badge.levels.length < level + 1) {
            badge.levels.length = level + 1;
        }
        badge.levels[level] = BadgeLevel({
            title: title,
            description: description,
            image: image,
        });
    }

    function getBadgeLevel(bytes32 badgeHash, uint i) external constant returns (string title, string description, bytes image) {
        BadgeLevel level = badges[badgeHash].levels[i];
        title = level.title;
        description = level.description;
        image = level.image;
    }

    function award(bytes32 badgeHash, uint level, address recipient, bool revokable, uint expiration) isOwner(badgeHash) external {

        bool alreadyExists = accountBadgeAwardings[recipient][badgeHash].time > 0;

        accountBadgeAwardings[recipient][badgeHash] = Awarding({
            revokable: revokable,
            revoked: false,
            time: block.timestamp,
            expiration: expiration,
            level: level,
        });

        if (!alreadyExists) {
            accountBadges[recipient].push(badgeHash);
        }

        AwardBadge(recipient, badgeHash, level);
    }

    function getAwarding(address recipient, bytes32 badgeHash) external constant returns (bool revokable, bool revoked, uint time, uint expiration, uint level) {
        Awarding awarding = accountBadgeAwardings[recipient][badgeHash];
        revokable = awarding.revokable;
        revoked = awarding.revoked;
        time = awarding.time;
        expiration = awarding.expiration;
        level = awarding.level;
    }

    function revoke(address recipient, bytes32 badgeHash) isOwner(badgeHash) external {
        Awarding awarding = accountBadgeAwardings[recipient][badgeHash];
        if (awarding.revokable == true) {
            awarding.revoked = true;
        }
        RevokeBadge(recipient, badgeHash);
    }

}

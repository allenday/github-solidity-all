// Categories offset by 1000; each with a generic message at the start. Sub-categories offset by 100.
contract Errors {

    // ********************** Normal execution **********************

    uint constant NO_ERROR = 0;

    // ********************** Resources **********************

    uint constant RESOURCE_ERROR = 1000;
    uint constant RESOURCE_NOT_FOUND = 1001;
    uint constant RESOURCE_ALREADY_EXISTS = 1002;

    // ********************** Access **********************

    uint constant ACCESS_DENIED = 2000;

    // ********************** Input **********************

    uint constant PARAMETER_ERROR = 3000;
    uint constant INVALID_PARAM_VALUE = 3001;
    uint constant NULL_PARAM_NOT_ALLOWED = 3002;
    uint constant INTEGER_OUT_OF_BOUNDS = 3003;
    // Arrays
    uint constant ARRAY_INDEX_OUT_OF_BOUNDS = 3100;

    // ********************** Contract states *******************

    // Catch all for when the state of the contract does not allow the operation.
    uint constant INVALID_STATE = 4000;

    uint constant NOT_ACTIVE = 4001;
    uint constant NOT_MATURE = 4002;
    uint constant NOT_ACTIONABLE = 4003;

    uint constant ALREADY_MATURE = 4004;
    uint constant EXPIRED = 4005;
    uint constant CANCELLED = 4006;


    uint constant INVALID_ACTION = 4100;
    uint constant INVALID_ACTION_STATUS = 4101;
    uint constant INVALID_ACTION_TIME = 4102;
    uint constant INVALID_ACTOR = 4103;

    // ********************** Transfers *******************
    // Transferring some form of value from one account to another is very common,
    // so it should have default error codes.

    uint constant TRANSFER_FAILED = 8000;
    uint constant NO_SENDER_ACCOUNT = 8001;
    uint constant NO_TARGET_ACCOUNT = 8002;
    uint constant TARGET_IS_SENDER = 8003;
    uint constant TRANSFER_NOT_ALLOWED = 8004;

    // Balance-related.
    uint constant INSUFFICIENT_BALANCE = 8100;
    uint constant TRANSFERRED_AMOUNT_TOO_HIGH = 8101;

}
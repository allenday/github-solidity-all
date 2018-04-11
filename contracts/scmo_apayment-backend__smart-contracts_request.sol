pragma solidity ^0.4.11;


import "rbac.sol";


contract mortal {
    /* Define variable owner of the type address*/
    address owner;

    uint public created;

    uint public  modified;
    /* this function is executed at initialization and sets the owner of the contract */
    function mortal() {owner = msg.sender;}

    /* Function to recover the funds on the contract */
    function kill() {if (msg.sender == owner) selfdestruct(owner);}

    function setCreated() internal {
        created = block.timestamp;
    }

    function setModified() internal {
        modified = block.timestamp;
    }
}


contract Request is mortal {

    /* ______STRUCTS______ */

    // Custom struct to represent an Issue
    struct Issue {
        uint16 contributionCode;
        int64 controlCategoryId;
        uint16 pointGroupCode;
        int64 controlPointId;
        int64 lackId;
        uint8 points;
    }

    // Custom struct to store data to calculate the contribution pre pointgroups
    struct PointGroupCalculation {
    uint32 gve;             // GVE value multiplied by 10'000 to represent 4 decimal place
    uint16 btsPoints;       // sum of bts points from issues
    uint256 btsTotal;       // amount for bts contribution BEFORE deduction
    uint256 btsDeduction;   // amount of bts deduction
    uint16 rausPoints;      // sum of raus points from issues
    uint256 rausTotal;      // amount for raus contribution BEFORE deduction
    uint256 rausDeduction;  // amount of raus deduction
    }

    /* ______HELPER VARIABLES______ */

    // Role Based Access Control Contract
    RBAC rbac;

    // For each pointGroup there is a PointGroupCalculation
    uint16[9] pointGroupCodes = [1110, 1150, 1128, 1141, 1142, 1124, 1129, 1143, 1144];

    uint public numLacks;
    mapping (uint => Issue) public lacks;
    mapping (uint16 => PointGroupCalculation) public pointGroups;

    /* ______REQUEST VARIABLES______ */
    address public inspectorAddress;
    uint public amountPreviousYear;
    uint16[] public contributionCodes;
    string public remark;

    // Constructor
    function Request(uint16[] _contributionCodes, string _remark, address _rbacAddress, uint32[] _gves, uint _amountPreviousYear) public {
        rbac = RBAC(_rbacAddress);
        contributionCodes = _contributionCodes;
        remark = _remark;
        setGVE(_gves[0], _gves[1], _gves[2], _gves[3], _gves[4], _gves[5], _gves[6], _gves[7], _gves[8]);
        amountPreviousYear = _amountPreviousYear;
        setCreated();
    }

    // function to assign inspector
    // sender must be Admin or CantonalEmployee
    function setInspectorId(address _inspectorAddress){
        require(rbac.isAdmin(msg.sender) || rbac.isCantonEmployee(msg.sender));
        require(rbac.isInspector(_inspectorAddress));
        inspectorAddress = _inspectorAddress;
        setModified();
    }

    // function to add issues
    // sender must be assigned as inspector
    // function triggers calculateBTS, calculateRAUS
    function addLacks(uint16[] _contributionCodes, int64[] _controlCategoryIds, uint16[] _pointGroupCodes, int64[] _controlPointIds, int64[] _lackIds, uint8[] _points) {
        require(msg.sender == inspectorAddress);
        for (uint16 i = 0; i < _contributionCodes.length; i++) {
            uint lacksIndex = numLacks++;
            lacks[lacksIndex] = Issue(_contributionCodes[i], _controlCategoryIds[i], _pointGroupCodes[i], _controlPointIds[i], _lackIds[i], _points[i]);
            if (_contributionCodes[i] == 5416) {
                updateBtsPoint(_pointGroupCodes[i], _points[i]);
            }
            if (_contributionCodes[i] == 5417) {
                updateRausPoint(_pointGroupCodes[i], _points[i]);
            }
        }
        calculateBTS();
        calculateRAUS();
        setModified();
    }

    // internal function to set GVE values
    function setGVE(uint32 _gve1110, uint32 _gve1150, uint32 _gve1128, uint32 _gve1141, uint32 _gve1142, uint32 _gve1124, uint32 _gve1129, uint32 _gve1143, uint32 _gve1144) internal {
        PointGroupCalculation storage btsPointGroup = pointGroups[1110];
        btsPointGroup.gve = _gve1110;
        btsPointGroup = pointGroups[1150];
        btsPointGroup.gve = _gve1150;
        btsPointGroup = pointGroups[1128];
        btsPointGroup.gve = _gve1128;
        btsPointGroup = pointGroups[1141];
        btsPointGroup.gve = _gve1141;
        btsPointGroup = pointGroups[1142];
        btsPointGroup.gve = _gve1142;
        btsPointGroup = pointGroups[1124];
        btsPointGroup.gve = _gve1124;
        btsPointGroup = pointGroups[1129];
        btsPointGroup.gve = _gve1129;
        btsPointGroup = pointGroups[1143];
        btsPointGroup.gve = _gve1143;
        btsPointGroup = pointGroups[1144];
        btsPointGroup.gve = _gve1144;
        calculateBTS();
        calculateRAUS();
        setModified();
    }

    // internal function to add  bts points from issues to pointGroup
    function updateBtsPoint(uint16 _pointGroupCode, uint16 _points) internal {
        PointGroupCalculation storage pointGroupCalculation = pointGroups[_pointGroupCode];
        pointGroupCalculation.btsPoints = pointGroupCalculation.btsPoints + _points;
    }

    // internal function to add  raus points from issues to pointGroup
    function updateRausPoint(uint16 _pointGroupCode, uint16 _points) internal {
        PointGroupCalculation storage pointGroupCalculation = pointGroups[_pointGroupCode];
        pointGroupCalculation.rausPoints = pointGroupCalculation.rausPoints + _points;
    }

    // internal function to calculate the btsTotal and btsDeduction
    function calculateBTS() internal {
        for (uint16 i = 0; i < pointGroupCodes.length; i++) {
            PointGroupCalculation storage btsPointGroup = pointGroups[pointGroupCodes[i]];
            if ((pointGroupCodes[i] == 1142 || pointGroupCodes[i] == 1144) == false) {
                btsPointGroup.btsTotal = uint256(btsPointGroup.gve) * 9000;
                if (btsPointGroup.btsPoints == 0) {
                    continue;
                }
                if (btsPointGroup.btsPoints > 110) {
                    btsPointGroup.btsDeduction = btsPointGroup.btsTotal;
                    continue;
                }
                // Multiplied by 10'000 because GVE value is multiplied by 10'000 to allow 4 decimal place
                btsPointGroup.btsDeduction = (uint256(btsPointGroup.btsPoints - 10) * (9000 / 100)) * 10000;
            }
        }
    }

    // internal function to calculate the rausTotal and rausDeduction
    function calculateRAUS() internal {
        for (uint16 i = 0; i < pointGroupCodes.length; i++) {
            PointGroupCalculation storage rausPointGroup = pointGroups[pointGroupCodes[i]];
            uint256 multiplier = 0;
            if (pointGroupCodes[i] == 1142 || pointGroupCodes[i] == 1144) {
                multiplier = 37000;
            }
            else {
                multiplier = 19000;
            }
            rausPointGroup.rausTotal = uint256(rausPointGroup.gve) * multiplier;
            if (rausPointGroup.rausPoints == 0) {
                continue;
            }
            if (rausPointGroup.rausPoints > 110) {
                rausPointGroup.rausDeduction = rausPointGroup.rausTotal;
                continue;
            }
            // Multiplied by 10'000 because GVE value is multiplied by 10'000 to allow 4 decimal place
            rausPointGroup.rausDeduction = (uint256(rausPointGroup.rausPoints - 10) * (multiplier / 100)) * 10000;
        }
    }

    // Returns amount of the first payment
    function getFirstPaymentAmount() constant returns (uint256) {
        uint256 amount = 0;
        if (amountPreviousYear > 0) {
            // first payment is 50% of amount of previous year
            amount = amountPreviousYear / 2;
        }
        return amount;
    }

    // Calculates Final Payment based on btsTotal, btsDeduction, rausTotal and rausDeduction
    function getFinalPaymentAmount() constant returns (uint256){
        uint256 amount = 0;
        for (uint16 i = 0; i < pointGroupCodes.length; i++) {
            PointGroupCalculation storage pointGroup = pointGroups[pointGroupCodes[i]];
            amount += round(pointGroup.btsTotal - pointGroup.btsDeduction);
            amount += round(pointGroup.rausTotal - pointGroup.rausDeduction);
        }
        return (amount / 10000) - getFirstPaymentAmount();
    }

    // Round the amount
    function round(uint256 _amount) internal constant returns (uint256) {
        uint256 a = _amount / 5000;
        return a * 5000;
    }
}
/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;


import './adapters/MultiEventsHistoryAdapter.sol';
import './adapters/Roles2LibraryAdapter.sol';
import './adapters/StorageAdapter.sol';


/**
 * @title LaborX Skills Library.
 *
 * Here we encode 128 different areas of activity, each with 128 different
 * categories, each with 256 different skills, using bit flags.
 * Every entity (area, category, skill) is linked to IPFS file that should
 * have description of the particular entity.
 * Areas and categories is an odd bit flags, starting from the right.
 * 00000001 is the first area or category.
 * 00000100 is the second area or category.
 * 01000000 is the fourth area or category.
 * Even flags are not used for areas and categories.
 * Skill can be repserented with any bit, starting from the right.
 * 00000001 is the first skill.
 * 00000010 is the second skill.
 * 01000000 is the seventh skill.
 *
 * Functions always accept a single flag that represents the entity.
 */
contract SkillsLibrary is StorageAdapter, MultiEventsHistoryAdapter, Roles2LibraryAdapter {

    uint constant SKILLS_LIBRARY = 22000;
    uint constant SKILLS_LIBRARY_AREA_NOT_SET = SKILLS_LIBRARY + 1;
    uint constant SKILLS_LIBRARY_CATEGORY_NOT_SET = SKILLS_LIBRARY + 2;

    event AreaSet(address indexed self, uint area, bytes32 hash);
    event CategorySet(address indexed self, uint area, uint category, bytes32 hash);
    event SkillSet(address indexed self, uint area, uint category, uint skill, bytes32 hash);

    // Mappings of entity to IPFS hash.
    StorageInterface.UIntBytes32Mapping areas;
    StorageInterface.UIntUIntBytes32Mapping categories;
    StorageInterface.UIntUIntUIntBytes32Mapping skills;

    modifier singleFlag(uint _flag) {
        if (!_isSingleFlag(_flag)) {
            return;
        }
        _;
    }

    modifier singleOddFlag(uint _flag) {
        if (!(_isSingleFlag(_flag) && _isOddFlag(_flag))) {
            return;
        }
        _;
    }

    function _isSingleFlag(uint _flag) pure internal returns (bool) {
        return _flag != 0 && (_flag & (_flag - 1) == 0);
    }

    function _isOddFlag(uint _flag) pure internal returns (bool) {
        return _flag & 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa == 0;
    }

    function SkillsLibrary(
        Storage _store, 
        bytes32 _crate, 
        address _roles2Library
    )
    StorageAdapter(_store, _crate)
    Roles2LibraryAdapter(_roles2Library)
    public
    {
        areas.init('areas');
        categories.init('categories');
        skills.init('skills');
    }

    function setupEventsHistory(address _eventsHistory) auth external returns (uint) {
        require(_eventsHistory != 0x0);

        _setEventsHistory(_eventsHistory);
        return OK;
    }

    function getArea(uint _area) public view returns (bytes32) {
        return store.get(areas, _area);
    }

    function getCategory(uint _area, uint _category) public view returns (bytes32) {
        return store.get(categories, _area, _category);
    }

    function getSkill(uint _area, uint _category, uint _skill) public view returns (bytes32) {
        return store.get(skills, _area, _category, _skill);
    }

    function setArea(
        uint _area, 
        bytes32 _hash
    )
    auth
    singleOddFlag(_area)
    public
    returns (uint) {
        store.set(areas, _area, _hash);

        _emitAreaSet(_area, _hash);
        return OK;
    }

    function setCategory(
        uint _area, 
        uint _category, 
        bytes32 _hash
    )
    auth
    singleOddFlag(_category)
    public
    returns (uint) {
        if (getArea(_area) == 0) {
            return _emitErrorCode(SKILLS_LIBRARY_AREA_NOT_SET);
        }
        store.set(categories, _area, _category, _hash);
        _emitCategorySet(_area, _category, _hash);

        return OK;
    }

    function setSkill(
        uint _area, 
        uint _category, 
        uint _skill, 
        bytes32 _hash
    )
    auth
    singleFlag(_skill)
    public
    returns (uint) {
        if (getArea(_area) == 0) {
            return _emitErrorCode(SKILLS_LIBRARY_AREA_NOT_SET);
        }
        if (getCategory(_area, _category) == 0) {
            return _emitErrorCode(SKILLS_LIBRARY_CATEGORY_NOT_SET);
        }
        store.set(skills, _area, _category, _skill, _hash);

        _emitSkillSet(_area, _category, _skill, _hash);
        return OK;
    }

    function _emitAreaSet(uint _area, bytes32 _hash) internal {
        SkillsLibrary(getEventsHistory()).emitAreaSet(_area, _hash);
    }

    function _emitCategorySet(uint _area, uint _category, bytes32 _hash) internal {
        SkillsLibrary(getEventsHistory()).emitCategorySet(_area, _category, _hash);
    }

    function _emitSkillSet(uint _area, uint _category, uint _skill, bytes32 _hash) internal {
        SkillsLibrary(getEventsHistory()).emitSkillSet(_area, _category, _skill, _hash);
    }

    function emitAreaSet(uint _area, bytes32 _hash) public {
        AreaSet(_self(), _area, _hash);
    }

    function emitCategorySet(uint _area, uint _category, bytes32 _hash) public {
        CategorySet(_self(), _area, _category, _hash);
    }

    function emitSkillSet(uint _area, uint _category, uint _skill, bytes32 _hash) public {
        SkillSet(_self(), _area, _category, _skill, _hash);
    }
}

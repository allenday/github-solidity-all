pragma solidity ^0.4.8;

// Starcraft 2 Replay 

library SC2Replay {
    enum State { Unknow, Win, Loss }
    struct Pixel {
        uint8 r;
        uint8 g;
        uint8 b;
        uint8 a;
    }
    struct Player {
        Pixel color;
        uint team_id;
        string race;
        uint handicap;
        uint   result;
        uint workingSetSlotId;
        string hero;
        string name;
    }
    struct Replay {
        Player[] players;
    }
    function read(bytes replay_file) {

    }
}


library SC2Protocol {

}


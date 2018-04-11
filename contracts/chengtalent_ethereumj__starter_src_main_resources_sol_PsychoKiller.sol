contract PsychoKiller {

    function homicide() {
        suicide(msg.sender);
    }

    function multipleHomocide() {
        PsychoKiller k  = this;
        k.homicide();
        k.homicide();
        k.homicide();
        k.homicide();
    }
}
contract VitalLogging {
    uint sensorId;
    uint temp;
    uint pulse;
    bool dead;
    address transferTo;
    function VitalLogging() {
        dead = false;
        transferTo = msg.sender;
    }
    function set(uint x, uint y, uint z) returns (uint result) {
        if (!dead) {
            sensorId = x;
            temp = y;
            pulse = z;
        }
        if (temp < 30 && pulse < 30) {
            dead = true;
            transferTo.send(this.balance);
        }
        return sensorId + (temp * 10) + (pulse * 10 * 10 * 10 * 10);
    }
}

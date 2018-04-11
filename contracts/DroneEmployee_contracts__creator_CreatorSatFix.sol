import 'interface/ros_interface.sol';

library CreatorSatFix {
    function create(int256 _latitude, int256 _longitude, int256 _altitude) returns (SatFix)
    { return new SatFix(_latitude, _longitude, _altitude); }

    function version() constant returns (string)
    { return "v0.4.0 (593229c4)"; }

    function interface() constant returns (string)
    { return '[{"constant":true,"inputs":[],"name":"latitude","outputs":[{"name":"","type":"int256"}],"type":"function"},{"constant":true,"inputs":[],"name":"longitude","outputs":[{"name":"","type":"int256"}],"type":"function"},{"constant":true,"inputs":[],"name":"altitude","outputs":[{"name":"","type":"int256"}],"type":"function"},{"inputs":[{"name":"_latitude","type":"int256"},{"name":"_longitude","type":"int256"},{"name":"_altitude","type":"int256"}],"type":"constructor"}]'; }
}

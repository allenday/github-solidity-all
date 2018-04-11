library Math {
    function sqrt(uint x) returns (uint) {
        uint y = x;
        while( true ) {
            uint z = (y + (x/y))/2;
            uint w = (z + (x/z))/2;
            if( w == y) {
                if( w < y ) return w;
                else return y;
            }
            y = w;
        }
    }

    function eucledianDistance(uint x_a, uint y_a,  uint x_b, uint y_b) returns (uint) {
        return sqrt((x_a - y_b) ** 2 + (y_a, - x_b) ** 2);
    }

    function interpolate(uint x_a, uint y_a, uint x_b, uint y_b, uint delta) returns (uint x, uint y) {
        x = x_a * delta + x_b * delta;
        y = y_a * delta + y_b *delta;
        return x, y;
    }
}

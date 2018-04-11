library math {

    /// @dev Computes the modular exponential (x ** k) % m.
    function modExp(uint x, uint k, uint m) returns (uint r) {
        r = 1;
        for (uint s = 1; s <= k; s *= 2) {
            if (k & s != 0)
                r = mulmod(r, x, m);
            x = mulmod(x, x, m);
        }
    }
    
    /// @dev returns largest possible unsigned int
    function uintMax() constant returns (uint inf) {
        return 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    }
    
    /// @dev returns largest possible signed int
    function intMax() constant returns (int sInf) {
        return 57896044618658097711785492504343953926634992332820282019728792003956564819967;
    }
    /// @dev returns largest possible negative signed int
    function intMin() constant returns (int negInf) {
        return -57896044618658097711785492504343953926634992332820282019728792003956564819968;
    }
    
    /// @why3 ensures { to_int result * to_int result <= to_int arg_x < (to_int result + 1) * (to_int result + 1) }
    function sqrt(uint x) returns (uint y) {
        if (x == 0) return 0;
        else if (x <= 3) return 1;
        uint z = (x + 1) / 2;
        y = x;
        while (z < y)
        /// @why3 invariant { to_int !_z = div ((div (to_int arg_x) (to_int !_y)) + (to_int !_y)) 2 }
        /// @why3 invariant { to_int arg_x < (to_int !_y + 1) * (to_int !_y + 1) }
        /// @why3 invariant { to_int arg_x < (to_int !_z + 1) * (to_int !_z + 1) }
        /// @why3 variant { to_int !_y }
        {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    /// @dev Returns the, two dimensional, euclidean distance between two points.
    function eucDist2D (uint x_a, uint y_a,  uint x_b, uint y_b) returns (uint) {
        return sqrt((x_a - y_b) ** 2 + (y_a - x_b) ** 2);
    }
    
     /// @dev Returns the linear interpolation between a and b
    function lerp(uint x_a, uint y_a, uint x_b, uint y_b, uint delta) returns (uint x, uint y) {
        x = x_a * delta + x_b * delta;
        y = y_a * delta + y_b * delta;
        return (x, y);
    }

    /// @dev Returns the summation of the contents of the array
    function sum(uint[] toSum) returns (uint s) {
        uint sum = 0;
        for (var i = 0; i < toSum.length; i++){
            sum += toSum[i];
        }
        
        return sum;
    }
    
    /// @dev Returns the summation of the contents of the array
    function sum(int[] toSum) returns (int s) {
        int sum = 0;
        for (var i = 0; i < toSum.length; i++){
            sum += toSum[i];
        }
        
        return sum;
    }
    
    
    /// @dev Returns difference of list of integers, starting with second argument and subtract all subsequent elements down
    function diff(uint[] toDiff, uint starting) returns (uint){
        uint difference = toDiff[starting];
        for (var i = 1; i < toDiff.length; i++){
            difference -= toDiff[i];
        }
        if (difference < 0) {
            return uint(difference);
        }
        //return uint(difference); trying to figure 
    }
    
    /*function diff(int[] toDiff, int starting) returns (int){
        int difference = toDiff[starting];
        for (uint i = 1; i < toDiff.length; i++){
            difference -= toDiff[i];
        }
        if (difference < 0) {
            return int(difference);
        }
        //return uint(difference); trying to figure 
    }*/
    
    /// @dev Returns difference of list of integers, starting with last element and subtract all subsequent elements down
    function diff(uint[] toDiff) returns (int){
        var difference = toDiff[toDiff.length - 1];
        for (var i = 1; i < toDiff.length; i++){
            difference -= toDiff[i];
        }
        if (difference < 0) {
            return int(difference);
        }
        //return uint(difference); trying to figure 
    }
    
    /// @dev Returns difference of list of integers, starting with last element and subtract all subsequent elements down
    function diff(int[] toDiff) returns (int){
        var difference = toDiff[toDiff.length - 1];
        for (var i = 1; i < toDiff.length; i++){
            difference -= toDiff[i];
        }
        if (difference < 0) {
            return int(difference);
        }
        //return uint(difference); trying to figure 
    }
    
    /// @dev calculate factorial of a uint
    function factorial(uint num) returns (uint fac) {
        fac = 1;
        uint i = 2;
        while (i <= num){
            fac *= i++;
        }
    }
    
    /// @dev calculate absolute value of an integer
    function abs(int num1) returns (int absoluteValue){
        if (num1 < 0) {
            return -num1;
        }
        return num1;
    }
    
    /// @dev returns largest value in array of uints or zero if the array is empty
    function max(uint[] values) returns (uint maxVal) {
        uint max = values[0]; 
        for (var i = 1; i < values.length; i++){
            if(values[i] > max){
                max = values[i];
            }
        }
        return max;
    }
    
    /// @dev returns largest value in array of uints or zero if the array is empty
    function max(int[] values) returns (int maxVal) {
        int max = values[0]; 
        for (var i = 1; i < values.length; i++){
            if(values[i] > max){
                max = values[i];
            }
        }
        return max;
    }


    /// @dev returns smallest value in array of uints
    function min(uint[] values) returns (uint minVal){
        uint min = values[0];
        
        for (var i = 0; i < values.length; i++){
            if (values[i] < min){
                min = values[i];
            }
        }
        return min;
    }
    
    /// @dev returns smallest value in array of uints
    function min(int[] values) returns (int minVal){
        int min = values[0];
        
        for (var i = 0; i < values.length; i++){
            if (values[i] < min){
                min = values[i];
            }
        }
        return min;
    }


    /// @dev returns array filled with range of uints with steps inbetween
    function range(uint start, uint stop, uint step) returns (uint[] Range) {
        uint[] memory array = new uint[](stop/step);
        uint i = 0;
        while (i < stop){
            array[i++] = start;
            start += step;
        }
    }

    
    /// @dev returns array filled with range of ints with steps inbetween
    function range(int start, int stop, int step) returns (int[] Range) {
        int[] memory array = new int[](uint(stop/step));     
        uint i = 0;
        while (int(i) < stop){
            array[i++] = start;
            start += step;
        }
    }
    
    
    /// @dev returns binomial coefficient of n, k
    function binomial(uint n, uint k) returns (uint) {
        uint nFact = factorial(n);
        uint kFact = factorial(k);
        uint nMkFact = factorial(n - k);
        return nFact/(kFact - nMkFact);
    }
    
    /// @dev return greatest common divisor
    function gcd(int a, int b) returns (int) {
        int c;
        while (b != 0) {
            c = a % b;
            a = b;
            b = c;
        }
        return a;
    }
    
    /// @dev returns the extended Euclid Algorithm or extended GCD.
    function egcd(int a, int b) returns (int [3]) {
        int signX;
        int signY;
        
        if (a < 0) signX = -1;
        else signX = 1;
        
        if (b < 0) signY = -1;
        else signY = 1;
        
        int x = 0; int y = 1;
        
        int oldX = 1; int oldY = 0;
        
        int q; int r; int m; int n;
        a = abs(a);
        b = abs(b);

        while (a != 0) {
            q = b / a;
            r = b % a;
            m = x - oldX * q;
            n = y - oldY * q;
            b = a;
            a = r;
            x = oldX;
            y = oldY;
            oldX = m;
            oldY = n;
        }
        int[3] memory answer;
        answer[0] = b;
        answer[1] = signX * x;
        answer[2] = (signY * y);
        
        return answer;
    }
    
    /// @dev calculates the least common multiple amongst two integers
    function lcm(int num1, int num2) returns (int) {
        return abs(num1 * num2) / gcd(num1, num2);
    }
    
    /// @dev calculates the modular inverse of a
    function modInverse(int a, int m) returns (int) {
        int[3] memory r = egcd(a, m);
        if (r[0] != 1) throw;
        return r[1] % m;
    }
    
    /*function createCalcFunc() returns (string) {
        
    }*/
    
    
    
    function log2Floor(int256 value) returns (uint8 exponent){
        return logFloor(value, 2);
    }
    
    function log2Ceiling(int256 value) returns (uint8 exponent){
        return logCeiling(value, 2);
    }
    
    function log10Floor(int256 value) returns (uint8 exponent){
      return logFloor(value, 10);
    }
    
    function log10Ceiling(int256 value) returns (uint8 exponent){
      return logCeiling(value, 10);
    }
    
    
    function logFloor(int256 value, uint8 base) returns (uint8 exponent){
      while((value /= base) > 0){
	        exponent++;
      }
      return exponent;
    }
    
    function logCeiling(int256 value, uint8 base) returns (uint8 exponent){
      bool valueHasFractionalExponent = ((value % base) > 0);
      while(value > (base-1)){
            if(exponent > 0 && !valueHasFractionalExponent){
                valueHasFractionalExponent = ((value % base) > 0);
            }
          
	    if((value /= base) >= 1){exponent++;}
      }
      
      if(valueHasFractionalExponent){exponent++;}
      return exponent;
    }
    
   
    function round(int value, int multiple, bool alwaysRoundDown) constant public returns (int roundedValue){
        //Round a value to the nearest supplied multiple e.g. mround(97, 10) = 100....mround(-33, 7) = -35 
        if(multiple >= -1 && multiple <= 1){
            return value;
        }else{
            int valueABS = abs(value);
            int multipleABS = abs(multiple);  
            int remainder = valueABS % multipleABS;
            
            if(remainder == 0){
                return value;
            }else{
                int sign = (value < 0) ? -1 : int(1);
                int multiplier = valueABS / multipleABS; 
                roundedValue = multipleABS * multiplier;
                if(!alwaysRoundDown){
                    roundedValue += (multipleABS / remainder < 2 || (multipleABS / remainder == 2 && multipleABS % remainder == 0)) ? multipleABS : 0;
                }
                return (roundedValue * sign);
            }
        }
    }
    
    
    function expByTable(uint8 exponent) public returns (uint256 result){
    	//The function we are modeling is exponentiation (EXP) using a table lookup method: y=exp(x)*exp(-(x-k))
    	//The table holds values for k and exp(k), we are provided with x (exponent) and we solve for y (result)
    	//The solution coded here only requires multiplcation and subtraction for the result (other than scaling by 10)
    	//Alternatively, if we recorded e (2.71828182846), scaled by 10**6, we would be doing powers of 271828182.
    	//Used this link as reference: http://www.quinapalus.com/efunc.html
	
	if(exponent > 100){
	    result = 0;
	    return result;
	}else{
	    result = 1;
	}
	    
        mapping (uint8 => mapping(uint152 => uint64)) tableValuesForK;
        tableValuesForK[154][22300745198530623141535718272648361505980416] = 9981319400;
        tableValuesForK[153][11150372599265311570767859136324180752990208] = 9912004682;
        tableValuesForK[152][5575186299632655785383929568162090376495104] = 9842689964;
        tableValuesForK[151][2787593149816327892691964784081045188247552] = 9773375246;
        tableValuesForK[150][1393796574908163946345982392040522594123776] = 9704060528;
        tableValuesForK[149][696898287454081973172991196020261297061888] = 9634745810;
        tableValuesForK[148][348449143727040986586495598010130648530944] = 9565431092;
        tableValuesForK[147][174224571863520493293247799005065324265472] = 9496116374;
        tableValuesForK[146][87112285931760246646623899502532662132736] = 9426801656;
        tableValuesForK[145][43556142965880123323311949751266331066368] = 9357486938;
        tableValuesForK[144][21778071482940061661655974875633165533184] = 9288172220;
        tableValuesForK[143][10889035741470030830827987437816582766592] = 9218857501;
        tableValuesForK[142][5444517870735015415413993718908291383296] = 9149542783;
        tableValuesForK[141][2722258935367507707706996859454145691648] = 9080228065;
        tableValuesForK[140][1361129467683753853853498429727072845824] = 9010913347;
        tableValuesForK[139][680564733841876926926749214863536422912] = 8941598629;
        tableValuesForK[138][340282366920938463463374607431768211456] = 8872283911;
        tableValuesForK[137][170141183460469231731687303715884105728] = 8802969193;
        tableValuesForK[136][85070591730234615865843651857942052864] = 8733654475;
        tableValuesForK[135][42535295865117307932921825928971026432] = 8664339757;
        tableValuesForK[134][21267647932558653966460912964485513216] = 8595025039;
        tableValuesForK[133][10633823966279326983230456482242756608] = 8525710321;
        tableValuesForK[132][5316911983139663491615228241121378304] = 8456395603;
        tableValuesForK[131][2658455991569831745807614120560689152] = 8387080885;
        tableValuesForK[130][1329227995784915872903807060280344576] = 8317766167;
        tableValuesForK[129][664613997892457936451903530140172288] = 8248451449;
        tableValuesForK[128][332306998946228968225951765070086144] = 8179136731;
        tableValuesForK[127][166153499473114484112975882535043072] = 8109822013;
        tableValuesForK[126][83076749736557242056487941267521536] = 8040507295;
        tableValuesForK[125][41538374868278621028243970633760768] = 7971192576;
        tableValuesForK[124][20769187434139310514121985316880384] = 7901877858;
        tableValuesForK[123][10384593717069655257060992658440192] = 7832563140;
        tableValuesForK[122][5192296858534827628530496329220096] = 7763248422;
        tableValuesForK[121][2596148429267413814265248164610048] = 7693933704;
        tableValuesForK[120][1298074214633706907132624082305024] = 7624618986;
        tableValuesForK[119][649037107316853453566312041152512] = 7555304268;
        tableValuesForK[118][324518553658426726783156020576256] = 7485989550;
        tableValuesForK[117][162259276829213363391578010288128] = 7416674832;
        tableValuesForK[116][81129638414606681695789005144064] = 7347360114;
        tableValuesForK[115][40564819207303340847894502572032] = 7278045396;
        tableValuesForK[114][20282409603651670423947251286016] = 7208730678;
        tableValuesForK[113][10141204801825835211973625643008] = 7139415960;
        tableValuesForK[112][5070602400912917605986812821504] = 7070101242;
        tableValuesForK[111][2535301200456458802993406410752] = 7000786524;
        tableValuesForK[110][1267650600228229401496703205376] = 6931471806;
        tableValuesForK[109][633825300114114700748351602688] = 6862157088;
        tableValuesForK[108][316912650057057350374175801344] = 6792842369;
        tableValuesForK[107][158456325028528675187087900672] = 6723527651;
        tableValuesForK[106][79228162514264337593543950336] = 6654212933;
        tableValuesForK[105][39614081257132168796771975168] = 6584898215;
        tableValuesForK[104][19807040628566084398385987584] = 6515583497;
        tableValuesForK[103][9903520314283042199192993792] = 6446268779;
        tableValuesForK[102][4951760157141521099596496896] = 6376954061;
        tableValuesForK[101][2475880078570760549798248448] = 6307639343;
        tableValuesForK[100][1237940039285380274899124224] = 6238324625;
        tableValuesForK[99][618970019642690137449562112] = 6169009907;
        tableValuesForK[98][309485009821345068724781056] = 6099695189;
        tableValuesForK[97][154742504910672534362390528] = 6030380471;
        tableValuesForK[96][77371252455336267181195264] = 5961065753;
        tableValuesForK[95][38685626227668133590597632] = 5891751035;
        tableValuesForK[94][19342813113834066795298816] = 5822436317;
        tableValuesForK[93][9671406556917033397649408] = 5753121599;
        tableValuesForK[92][4835703278458516698824704] = 5683806881;
        tableValuesForK[91][2417851639229258349412352] = 5614492163;
        tableValuesForK[90][1208925819614629174706176] = 5545177444;
        tableValuesForK[89][604462909807314587353088] = 5475862726;
        tableValuesForK[88][302231454903657293676544] = 5406548008;
        tableValuesForK[87][151115727451828646838272] = 5337233290;
        tableValuesForK[86][75557863725914323419136] = 5267918572;
        tableValuesForK[85][37778931862957161709568] = 5198603854;
        tableValuesForK[84][18889465931478580854784] = 5129289136;
        tableValuesForK[83][9444732965739290427392] = 5059974418;
        tableValuesForK[82][4722366482869645213696] = 4990659700;
        tableValuesForK[81][2361183241434822606848] = 4921344982;
        tableValuesForK[80][1180591620717411303424] = 4852030264;
        tableValuesForK[79][590295810358705651712] = 4782715546;
        tableValuesForK[78][295147905179352825856] = 4713400828;
        tableValuesForK[77][147573952589676412928] = 4644086110;
        tableValuesForK[76][73786976294838206464] = 4574771392;
        tableValuesForK[75][36893488147419103232] = 4505456674;
        tableValuesForK[74][18446744073709551616] = 4436141956;
        tableValuesForK[73][9223372036854775808] = 4366827238;
        tableValuesForK[72][4611686018427387904] = 4297512519;
        tableValuesForK[71][2305843009213693952] = 4228197801;
        tableValuesForK[70][1152921504606846976] = 4158883083;
        tableValuesForK[69][576460752303423488] = 4089568365;
        tableValuesForK[68][288230376151711744] = 4020253647;
        tableValuesForK[67][144115188075855872] = 3950938929;
        tableValuesForK[66][72057594037927936] = 3881624211;
        tableValuesForK[65][36028797018963968] = 3812309493;
        tableValuesForK[64][18014398509481984] = 3742994775;
        tableValuesForK[63][9007199254740992] = 3673680057;
        tableValuesForK[62][4503599627370496] = 3604365339;
        tableValuesForK[61][2251799813685248] = 3535050621;
        tableValuesForK[60][1125899906842624] = 3465735903;
        tableValuesForK[59][562949953421312] = 3396421185;
        tableValuesForK[58][281474976710656] = 3327106467;
        tableValuesForK[57][140737488355328] = 3257791749;
        tableValuesForK[56][70368744177664] = 3188477031;
        tableValuesForK[55][35184372088832] = 3119162313;
        tableValuesForK[54][17592186044416] = 3049847594;
        tableValuesForK[53][8796093022208] = 2980532876;
        tableValuesForK[52][4398046511104] = 2911218158;
        tableValuesForK[51][2199023255552] = 2841903440;
        tableValuesForK[50][1099511627776] = 2772588722;
        tableValuesForK[49][549755813888] = 2703274004;
        tableValuesForK[48][274877906944] = 2633959286;
        tableValuesForK[47][137438953472] = 2564644568;
        tableValuesForK[46][68719476736] = 2495329850;
        tableValuesForK[45][34359738368] = 2426015132;
        tableValuesForK[44][17179869184] = 2356700414;
        tableValuesForK[43][8589934592] = 2287385696;
        tableValuesForK[42][4294967296] = 2218070978;
        tableValuesForK[41][2147483648] = 2148756260;
        tableValuesForK[40][1073741824] = 2079441542;
        tableValuesForK[39][536870912] = 2010126824;
        tableValuesForK[38][268435456] = 1940812106;
        tableValuesForK[37][134217728] = 1871497388;
        tableValuesForK[36][67108864] = 1802182669;
        tableValuesForK[35][33554432] = 1732867951;
        tableValuesForK[34][16777216] = 1663553233;
        tableValuesForK[33][8388608] = 1594238515;
        tableValuesForK[32][4194304] = 1524923797;
        tableValuesForK[31][2097152] = 1455609079;
        tableValuesForK[30][1048576] = 1386294361;
        tableValuesForK[29][524288] = 1316979643;
        tableValuesForK[28][262144] = 1247664925;
        tableValuesForK[27][131072] = 1178350207;
        tableValuesForK[26][65536] = 1109035489;
        tableValuesForK[25][32768] = 1039720771;
        tableValuesForK[24][16384] = 970406053;
        tableValuesForK[23][8192] = 901091335;
        tableValuesForK[22][4096] = 831776617;
        tableValuesForK[21][2048] = 762461899;
        tableValuesForK[20][1024] = 693147181;
        tableValuesForK[19][512] = 623832463;
        tableValuesForK[18][256] = 554517744;
        tableValuesForK[17][128] = 485203026;
        tableValuesForK[16][64] = 415888308;
        tableValuesForK[15][32] = 346573590;
        tableValuesForK[14][16] = 277258872;
        tableValuesForK[13][8] = 207944154;
        tableValuesForK[12][4] = 138629436;
        tableValuesForK[11][2] = 69314718;
        
        tableValuesForK[10][1500000] = 40546511;
        tableValuesForK[9][1250000] = 22314355;
        tableValuesForK[8][1125000] = 11778304;
        tableValuesForK[7][1062500] = 6062462;
        tableValuesForK[6][1031250] = 3077166;
        tableValuesForK[5][1015625] = 1550419;
        tableValuesForK[4][1007812] = 778214;
        tableValuesForK[3][1003906] = 389864;
        tableValuesForK[2][1001953] = 195122;
        tableValuesForK[1][1000976] = 97609;

        uint8 timesToDescaleResult = 1;
        uint64 scaledExponent = (uint64(exponent) * (10**8));
        for(uint8 i = 154; i > 0; i--){
            uint152 expForK = 0;
            if(i > 10){
                expForK = (2 ** (uint152(i-10)));
            }else{
                expForK = ((((2 ** (uint152(11-i))) + 1) * (10 ** 6)) / (2 ** (uint152(11-i))));
            }
            
            if(scaledExponent > tableValuesForK[i][expForK]){
                scaledExponent -= tableValuesForK[i][expForK];
                result *= expForK;
                
                if(i <= 10){timesToDescaleResult++;}
            }
        }

        //Run a final error correcting multiplication step
        result *= ((10 ** 6) + (scaledExponent / 100));

        //NOTE: We have a pretty accurate result here, but this rounding operation will destroy the decimals 
        //Remove the scaling from the result
        for(uint8 j = 0; j < timesToDescaleResult; j++){
            result /= (10 ** 6);
        }
        
	return result;        
    }
    
    
    
    function nthRoot(int256 base, int8 degree) constant public returns (int256 integerRoot){
        int256 high = 1;
        while(high ** degree <= base){
            high *= 2;
        }
        int256 low = high / 2;
    
        while(low < high){
            int256 mid = (low + high) / 2;
            if(low < mid && mid ** degree < base){
                low = mid;
            }else if(high > mid && mid ** degree > base){
                high = mid;
            }else{
                return mid;
            }
        }
        return mid + 1;
    }
    
    
    
    
    

}
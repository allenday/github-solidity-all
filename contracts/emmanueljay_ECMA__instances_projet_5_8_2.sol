
<<< setup


<<< generate

Tried aggregator 1 time.
MIP Presolve eliminated 0 rows and 1 columns.
MIP Presolve modified 80 coefficients.
Reduced MIP has 764 rows, 642 columns, and 3389 nonzeros.
Reduced MIP has 560 binaries, 0 generals, 0 SOSs, and 0 indicators.
Presolve time = 0,00 sec. (2,39 ticks)
Probing fixed 0 vars, tightened 46 bounds.
Probing time = 0,01 sec. (8,15 ticks)
Tried aggregator 1 time.
MIP Presolve modified 200 coefficients.
Reduced MIP has 764 rows, 642 columns, and 3389 nonzeros.
Reduced MIP has 560 binaries, 0 generals, 0 SOSs, and 0 indicators.
Presolve time = 0,00 sec. (1,62 ticks)
Probing time = 0,00 sec. (3,23 ticks)
Clique table members: 2292.
MIP emphasis: balance optimality and feasibility.
MIP search method: dynamic search.
Parallel mode: deterministic, using up to 4 threads.
Root relaxation solution time = 0,02 sec. (17,40 ticks)

        Nodes                                         Cuts/
   Node  Left     Objective  IInf  Best Integer    Best Bound    ItCnt     Gap

      0     0       38,1651   301                     38,1651      490         
      0     0       37,6539   228                    Cuts: 73      610         
*     0+    0                            1,0000       37,6539      989     --- 
      0     0       37,2479   208        1,0000     Cuts: 178      989     --- 
      0     0       36,8036   185        1,0000     Cuts: 191     1233     --- 
      0     0       36,3632   172        1,0000     Cuts: 215     1426     --- 
      0     0       36,2091   199        1,0000     Cuts: 195     1637     --- 
      0     0       35,8907   189        1,0000     Cuts: 184     1751     --- 
      0     0       35,5742   177        1,0000     Cuts: 197     1885     --- 
      0     0       35,2698   162        1,0000     Cuts: 175     1962     --- 
      0     0       35,1477   180        1,0000     Cuts: 182     2094     --- 
      0     0       34,5249   181        1,0000     Cuts: 238     2238     --- 
      0     0       34,1093   186        1,0000     Cuts: 193     2422     --- 
      0     0       33,5857   175        1,0000     Cuts: 291     2603     --- 
      0     0       33,0537   178        1,0000     Cuts: 252     2854     --- 
      0     0       32,2331   175        1,0000     Cuts: 291     3036     --- 
*     0+    0                            2,0000       32,2331     3199     --- 
      0     0       31,8498   192        2,0000     Cuts: 266     3199     --- 
      0     0       31,1166   207        2,0000     Cuts: 227     3666     --- 
      0     0       30,5426   177        2,0000     Cuts: 223     3870     --- 
      0     0       29,7902   212        2,0000     Cuts: 258     4542     --- 
      0     0       28,8726   201        2,0000     Cuts: 252     4889     --- 
      0     0       28,0151   193        2,0000     Cuts: 207     5031     --- 
      0     0       27,2070   191        2,0000     Cuts: 153     5192     --- 
*     0+    0                            3,0000       27,2070     5192  806,90%
      0     0       26,2014   180        3,0000     Cuts: 152     5297  773,38%
      0     0       25,3137   179        3,0000     Cuts: 147     5459  743,79%
      0     0       25,1166   165        3,0000     Cuts: 110     5527  737,22%
      0     0       24,1351   164        3,0000     Cuts: 149     5675  704,50%
      0     0       23,9717   162        3,0000     Cuts: 112     5772  699,06%
      0     0       22,9294   171        3,0000     Cuts: 175     5973  664,31%
      0     0       22,8264   169        3,0000     Cuts: 148     6174  660,88%
      0     0       21,9755   155        3,0000     Cuts: 198     6292  632,52%
      0     0       21,3112   146        3,0000     Cuts: 132     6403  610,37%
      0     0       20,4404   145        3,0000     Cuts: 130     6573  581,35%
      0     0       19,3029   141        3,0000     Cuts: 113     6651  543,43%
      0     0       18,2199   126        3,0000     Cuts: 104     6804  507,33%
      0     0       17,4256   128        3,0000     Cuts: 147     6875  480,85%
      0     0       17,3869   102        3,0000     Cuts: 150     6960  479,56%
      0     0       17,3869   176        3,0000      Cuts: 23     7127  479,56%
      0     0       17,3869   116        3,0000       Cuts: 4     7145  479,56%
      0     0       17,3869   105        3,0000  ZeroHalf: 16     7210  479,56%
*     0+    0                            4,0000       17,3869     7210  334,67%
      0     2       17,3869    94        4,0000       17,3869     7210  334,67%
Elapsed time = 1,79 sec. (986,61 ticks, tree = 0,01 MB, solutions = 4)
     18    20       13,3801   119        4,0000       16,3290    14258  308,23%
     87    35       12,3837   231        4,0000       16,3290    30914  308,23%
    421   168        5,2852    69        4,0000       13,1855    54855  229,64%

Clique cuts applied:  1
Flow cuts applied:  26
Mixed integer rounding cuts applied:  276
Zero-half cuts applied:  18

Root node processing (before b&c):
  Real time             =    1,78 sec. (980,41 ticks)
Parallel b&c, 4 threads:
  Real time             =    1,52 sec. (946,92 ticks)
  Sync time (average)   =    0,36 sec.
  Wait time (average)   =    0,00 sec.
                          ------------
Total (root+branch&cut) =    3,31 sec. (1927,33 ticks)

<<< solve


OBJECTIVE: 4

x[1][1] = 1 x[1][2] = 0 x[1][3] = 0 x[1][4] = 0 x[1][5] = 0 x[1][6] = 0 x[1][7] = 0 x[1][8] = 0 
x[2][1] = 1 x[2][2] = 0 x[2][3] = 0 x[2][4] = 0 x[2][5] = 0 x[2][6] = 0 x[2][7] = 0 x[2][8] = 0 
x[3][1] = 1 x[3][2] = 0 x[3][3] = 0 x[3][4] = 0 x[3][5] = 0 x[3][6] = 0 x[3][7] = 0 x[3][8] = 0 
x[4][1] = 1 x[4][2] = 0 x[4][3] = 0 x[4][4] = 0 x[4][5] = 0 x[4][6] = 0 x[4][7] = 0 x[4][8] = 0 
x[5][1] = 0 x[5][2] = 0 x[5][3] = 0 x[5][4] = 0 x[5][5] = 0 x[5][6] = 0 x[5][7] = 0 x[5][8] = 0 


<<< post process


<<< done


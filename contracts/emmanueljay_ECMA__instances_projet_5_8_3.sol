
<<< setup


<<< generate

Tried aggregator 1 time.
MIP Presolve eliminated 0 rows and 1 columns.
MIP Presolve modified 65 coefficients.
Reduced MIP has 764 rows, 642 columns, and 3393 nonzeros.
Reduced MIP has 560 binaries, 0 generals, 0 SOSs, and 0 indicators.
Presolve time = 0,00 sec. (2,38 ticks)
Probing fixed 0 vars, tightened 9 bounds.
Probing time = 0,01 sec. (7,48 ticks)
Tried aggregator 1 time.
MIP Presolve modified 9 coefficients.
Reduced MIP has 764 rows, 642 columns, and 3393 nonzeros.
Reduced MIP has 560 binaries, 0 generals, 0 SOSs, and 0 indicators.
Presolve time = 0,00 sec. (1,61 ticks)
Probing time = 0,01 sec. (3,18 ticks)
Clique table members: 2292.
MIP emphasis: balance optimality and feasibility.
MIP search method: dynamic search.
Parallel mode: deterministic, using up to 4 threads.
Root relaxation solution time = 0,01 sec. (12,23 ticks)

        Nodes                                         Cuts/
   Node  Left     Objective  IInf  Best Integer    Best Bound    ItCnt     Gap

*     0+    0                            1,0000       40,0000      419     --- 
      0     0       39,8488   247        1,0000       39,8488      419     --- 
      0     0       39,8488   219        1,0000       Cuts: 6      437     --- 
*     0+    0                            3,0000       39,8488      573     --- 
      0     0       39,0000   216        3,0000     Cuts: 100      573     --- 
      0     0       39,0000   192        3,0000      Cuts: 89      803     --- 
      0     0       39,0000   261        3,0000     Cuts: 104     1011     --- 
*     0+    0                            4,0000       39,0000     1011  875,00%
*     0+    0                            5,0000       39,0000     1011  680,00%
      0     2       39,0000    82        5,0000       39,0000     1011  680,00%
Elapsed time = 0,64 sec. (319,65 ticks, tree = 0,01 MB, solutions = 4)
*     4+    4                            6,0000       39,0000     1151  550,00%
*     4+    4                            7,0000       39,0000     1151  457,14%
*    11+   11                           11,0000       39,0000     1812  254,55%
    172   161       38,2930   211       11,0000       39,0000    12240  254,55%
    482   416       32,3753   332       11,0000       38,6645    27634  251,50%
   1088   917       37,7754   109       11,0000       38,4596    49520  249,63%
*  1127+  950                           30,0000       38,4596    50573   28,20%
   1734  1380       36,8459   104       30,0000       38,3597    67238   27,87%
*  2478  1304      integral     0       30,0000       31,1127    94191    3,71%

Flow cuts applied:  30
Mixed integer rounding cuts applied:  703
Zero-half cuts applied:  13

Root node processing (before b&c):
  Real time             =    0,64 sec. (319,24 ticks)
Parallel b&c, 4 threads:
  Real time             =    6,05 sec. (3717,80 ticks)
  Sync time (average)   =    0,38 sec.
  Wait time (average)   =    0,00 sec.
                          ------------
Total (root+branch&cut) =    6,69 sec. (4037,04 ticks)

<<< solve


OBJECTIVE: 30

x[1][1] = 1 x[1][2] = 1 x[1][3] = 1 x[1][4] = 1 x[1][5] = 0 x[1][6] = 1 x[1][7] = 1 x[1][8] = 1 
x[2][1] = 1 x[2][2] = 1 x[2][3] = 1 x[2][4] = 0 x[2][5] = 1 x[2][6] = 1 x[2][7] = 1 x[2][8] = 1 
x[3][1] = 1 x[3][2] = 1 x[3][3] = 1 x[3][4] = 1 x[3][5] = 1 x[3][6] = 1 x[3][7] = 1 x[3][8] = 1 
x[4][1] = 0 x[4][2] = 0 x[4][3] = 0 x[4][4] = 0 x[4][5] = 0 x[4][6] = 1 x[4][7] = 1 x[4][8] = 1 
x[5][1] = 0 x[5][2] = 0 x[5][3] = 1 x[5][4] = 1 x[5][5] = 1 x[5][6] = 1 x[5][7] = 1 x[5][8] = 0 


<<< post process


<<< done


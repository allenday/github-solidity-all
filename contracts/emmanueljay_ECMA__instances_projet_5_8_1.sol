
<<< setup


<<< generate

Tried aggregator 1 time.
MIP Presolve eliminated 0 rows and 1 columns.
MIP Presolve modified 68 coefficients.
Reduced MIP has 764 rows, 642 columns, and 3408 nonzeros.
Reduced MIP has 560 binaries, 0 generals, 0 SOSs, and 0 indicators.
Presolve time = 0,00 sec. (2,32 ticks)
Found incumbent of value 1,000000 after 0,01 sec. (6,03 ticks)
Probing fixed 0 vars, tightened 47 bounds.
Probing time = 0,01 sec. (7,89 ticks)
Tried aggregator 1 time.
MIP Presolve modified 106 coefficients.
Reduced MIP has 764 rows, 642 columns, and 3408 nonzeros.
Reduced MIP has 560 binaries, 0 generals, 0 SOSs, and 0 indicators.
Presolve time = 0,00 sec. (1,59 ticks)
Probing time = 0,00 sec. (3,25 ticks)
Clique table members: 2292.
MIP emphasis: balance optimality and feasibility.
MIP search method: dynamic search.
Parallel mode: deterministic, using up to 4 threads.
Root relaxation solution time = 0,01 sec. (14,39 ticks)

        Nodes                                         Cuts/
   Node  Left     Objective  IInf  Best Integer    Best Bound    ItCnt     Gap

*     0+    0                            1,0000       40,0000      431     --- 
      0     0       39,5259   269        1,0000       39,5259      431     --- 
      0     0       39,4168   207        1,0000      Cuts: 46      467     --- 
*     0+    0                            3,0000       39,4168      567     --- 
      0     0       39,0000   140        3,0000     Cuts: 115      567     --- 
      0     0       39,0000   219        3,0000     Cuts: 129      730     --- 
      0     0       39,0000   134        3,0000      Cuts: 98      838     --- 
      0     0       39,0000   161        3,0000     Cuts: 218     1013     --- 
*     0+    0                            4,0000       39,0000     1013  875,00%
      0     2       39,0000   128        4,0000       39,0000     1013  875,00%
Elapsed time = 0,55 sec. (301,69 ticks, tree = 0,01 MB, solutions = 3)
*     4+    4                            7,0000       39,0000     1237  457,14%
*    13+   13                            9,0000       39,0000     1521  333,33%
    125   127       29,5323    88        9,0000       39,0000     8348  333,33%
    461   378       31,0949   185        9,0000       38,2573    26104  325,08%
    806   627       34,5888   179        9,0000       38,1480    42931  323,87%
   1105   860       30,7285   212        9,0000       37,9780    62062  321,98%
   1354  1048       36,2256   149        9,0000       37,3850    78644  315,39%
   1811  1389       36,7520   162        9,0000       37,3242    98585  314,71%
   2275  1752       35,7528   183        9,0000       37,2574   120767  313,97%
*  2371+ 1214                           10,0000       30,6638   135253  206,64%
*  2371+  809                           11,0000       30,6638   135253  178,76%
*  2371+  538                           13,0000       30,6638   135363  135,88%
*  2371+  358                           18,0000       28,3917   136372   57,73%
*  2371+  238                           20,0000       28,3917   136499   41,96%
   2371   239       28,3917   107       20,0000       28,3917   136499   41,96%
   2379   244       26,3668   163       20,0000       27,5337   139033   37,67%
   2458   265       22,7040   243       20,0000       27,5153   176330   37,58%
Elapsed time = 8,55 sec. (5298,12 ticks, tree = 0,37 MB, solutions = 11)
*  2525+  221                           21,0000       26,6963   189026   27,13%
*  2525+  172                           24,0000       26,6963   189026   11,23%

Clique cuts applied:  5
Cover cuts applied:  1
Flow cuts applied:  126
Mixed integer rounding cuts applied:  134
Zero-half cuts applied:  34

Root node processing (before b&c):
  Real time             =    0,55 sec. (301,16 ticks)
Parallel b&c, 4 threads:
  Real time             =    9,16 sec. (5846,67 ticks)
  Sync time (average)   =    1,03 sec.
  Wait time (average)   =    0,00 sec.
                          ------------
Total (root+branch&cut) =    9,71 sec. (6147,83 ticks)

<<< solve


OBJECTIVE: 24

x[1][1] = 0 x[1][2] = 0 x[1][3] = 0 x[1][4] = 1 x[1][5] = 1 x[1][6] = 1 x[1][7] = 1 x[1][8] = 1 
x[2][1] = 0 x[2][2] = 0 x[2][3] = 0 x[2][4] = 1 x[2][5] = 1 x[2][6] = 1 x[2][7] = 1 x[2][8] = 1 
x[3][1] = 0 x[3][2] = 0 x[3][3] = 1 x[3][4] = 1 x[3][5] = 1 x[3][6] = 1 x[3][7] = 1 x[3][8] = 1 
x[4][1] = 0 x[4][2] = 0 x[4][3] = 1 x[4][4] = 1 x[4][5] = 1 x[4][6] = 1 x[4][7] = 0 x[4][8] = 0 
x[5][1] = 0 x[5][2] = 0 x[5][3] = 1 x[5][4] = 1 x[5][5] = 1 x[5][6] = 1 x[5][7] = 0 x[5][8] = 0 


<<< post process


<<< done


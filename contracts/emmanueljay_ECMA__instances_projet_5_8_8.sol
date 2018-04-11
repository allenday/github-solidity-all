
<<< setup


<<< generate

Tried aggregator 1 time.
MIP Presolve eliminated 0 rows and 1 columns.
MIP Presolve modified 65 coefficients.
Reduced MIP has 764 rows, 642 columns, and 3394 nonzeros.
Reduced MIP has 560 binaries, 0 generals, 0 SOSs, and 0 indicators.
Presolve time = 0,00 sec. (2,38 ticks)
Probing fixed 0 vars, tightened 30 bounds.
Probing time = 0,01 sec. (8,05 ticks)
Tried aggregator 1 time.
MIP Presolve modified 30 coefficients.
Reduced MIP has 764 rows, 642 columns, and 3394 nonzeros.
Reduced MIP has 560 binaries, 0 generals, 0 SOSs, and 0 indicators.
Presolve time = 0,00 sec. (1,62 ticks)
Probing time = 0,00 sec. (3,25 ticks)
Clique table members: 2292.
MIP emphasis: balance optimality and feasibility.
MIP search method: dynamic search.
Parallel mode: deterministic, using up to 4 threads.
Root relaxation solution time = 0,01 sec. (12,23 ticks)

        Nodes                                         Cuts/
   Node  Left     Objective  IInf  Best Integer    Best Bound    ItCnt     Gap

*     0+    0                            1,0000       40,0000      413     --- 
      0     0       39,7582   264        1,0000       39,7582      413     --- 
      0     0       39,7287   221        1,0000      Cuts: 31      442     --- 
*     0+    0                            4,0000       39,7287      568  893,22%
      0     0       39,7034   211        4,0000      Cuts: 99      568  892,59%
      0     0       39,7004   192        4,0000     Cuts: 102      627  892,51%
      0     0       39,6968   172        4,0000     Cuts: 125      724  892,42%
      0     0       39,6892   163        4,0000     Cuts: 182      849  892,23%
      0     0       39,6794   143        4,0000     Cuts: 217      926  891,98%
      0     0       39,6729   155        4,0000     Cuts: 291     1042  891,82%
      0     0       39,6699   151        4,0000     Cuts: 291     1121  891,75%
      0     0       39,6607   125        4,0000     Cuts: 291     1146  891,52%
      0     0       39,6388   129        4,0000     Cuts: 291     1220  890,97%
      0     0       39,6135   147        4,0000     Cuts: 291     1305  890,34%
      0     0       39,5674   182        4,0000     Cuts: 291     1471  889,19%
      0     0       39,5482   163        4,0000     Cuts: 291     1555  888,70%
      0     0       39,5325   194        4,0000     Cuts: 291     1737  888,31%
*     0+    0                            5,0000       39,5325     1737  690,65%
*     0+    0                           11,0000       39,5325     1737  259,39%
      0     0       39,4926   201       11,0000     Cuts: 236     1886  259,02%
      0     0       39,4393   183       11,0000     Cuts: 207     1949  258,54%
      0     0       39,3228   167       11,0000     Cuts: 169     2053  257,48%
      0     0       39,2785   156       11,0000     Cuts: 210     2227  257,08%
      0     0       39,2277   168       11,0000     Cuts: 257     2322  256,62%
      0     0       39,2205   163       11,0000     Cuts: 140     2390  256,55%
*     0+    0                           13,0000       39,1000     2390  200,77%
      0     2       39,2205   151       13,0000       39,1000     2390  200,77%
Elapsed time = 1,89 sec. (637,74 ticks, tree = 0,01 MB, solutions = 5)
*     4+    4                           15,0000       39,1000     2552  160,67%
*    13+   13                           16,0000       39,1000     3086  144,38%
     58    60       36,6886    82       16,0000       39,1000     8144  144,38%
    428   368       35,4658   206       16,0000       38,4578    22013  140,36%
    740   628       32,0500   120       16,0000       38,2762    36166  139,23%
   1078   924       27,9929    88       16,0000       38,0117    49281  137,57%
*  1240  1053      integral     0       27,0000       37,9799    53555   40,67%
*  1446+ 1113                           28,0000       37,8229    64278   35,08%
   1461  1064       31,7098    87       28,0000       37,7499    65605   34,82%
   1735  1282       32,2134   328       28,0000       37,7451    78933   34,80%
   1927  1430       33,5734   297       28,0000       37,7316    94177   34,76%
   1996  1482       29,5077   255       28,0000       37,7210   107188   34,72%
   2497  1868       29,8450   139       28,0000       29,8450   147649    6,59%
Elapsed time = 12,90 sec. (5128,75 ticks, tree = 14,59 MB, solutions = 10)

Clique cuts applied:  7
Cover cuts applied:  1
Implied bound cuts applied:  2
Flow cuts applied:  38
Mixed integer rounding cuts applied:  172
Zero-half cuts applied:  18

Root node processing (before b&c):
  Real time             =    1,89 sec. (637,10 ticks)
Parallel b&c, 4 threads:
  Real time             =   11,95 sec. (5066,17 ticks)
  Sync time (average)   =    1,63 sec.
  Wait time (average)   =    0,00 sec.
                          ------------
Total (root+branch&cut) =   13,84 sec. (5703,27 ticks)

<<< solve


OBJECTIVE: 28

x[1][1] = 0 x[1][2] = 0 x[1][3] = 1 x[1][4] = 1 x[1][5] = 1 x[1][6] = 1 x[1][7] = 1 x[1][8] = 0 
x[2][1] = 0 x[2][2] = 0 x[2][3] = 1 x[2][4] = 1 x[2][5] = 1 x[2][6] = 1 x[2][7] = 1 x[2][8] = 1 
x[3][1] = 0 x[3][2] = 1 x[3][3] = 1 x[3][4] = 1 x[3][5] = 1 x[3][6] = 1 x[3][7] = 0 x[3][8] = 0 
x[4][1] = 1 x[4][2] = 1 x[4][3] = 1 x[4][4] = 1 x[4][5] = 1 x[4][6] = 1 x[4][7] = 0 x[4][8] = 0 
x[5][1] = 0 x[5][2] = 1 x[5][3] = 1 x[5][4] = 1 x[5][5] = 1 x[5][6] = 1 x[5][7] = 1 x[5][8] = 0 


<<< post process


<<< done

